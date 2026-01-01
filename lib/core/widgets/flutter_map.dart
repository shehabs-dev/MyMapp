import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mymap/core/widgets/searchbar.dart';

class MapViewer extends StatefulWidget {
  const MapViewer({super.key});

  @override
  State<MapViewer> createState() => _MapViewerState();
}

class _MapViewerState extends State<MapViewer> {
  // Variables here
  late AlignOnUpdate _alignPositionOnUpdate;
  late final StreamController<double?> _alignPositionStreamController;
  bool serviceIconEnabled = false;
  Timer? timer;
  LatLng cairoCenter = LatLng(30.0444, 31.2357);
  late final Stream<LocationMarkerPosition?> _positionStream;

  bool isAddingMarker = false;
  LatLng? newMarkerPosition;
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    _alignPositionOnUpdate = AlignOnUpdate.always;
    _alignPositionStreamController = StreamController<double?>();
    serviceCheckTimer();

    // Fake location stream for testing without GPS
    // _positionStream = Stream<LocationMarkerPosition?>.periodic(
    //   const Duration(seconds: 1),
    //   (_) => LocationMarkerPosition(
    //     latitude: 30.0444,
    //     longitude: 31.2357,
    //     accuracy: 1.0,
    //   ),
    // );

    // Wrap stream with error handling
    final rawStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        distanceFilter: 10,
        timeLimit: Duration(minutes: 1),
      ),
    );

    _positionStream = const LocationMarkerDataStreamFactory()
        .fromGeolocatorPositionStream(
          stream: rawStream.handleError((e) {
            debugPrint('Location stream error: $e');
          }),
        );
  }

  // Will be set when user location is known

  //____________________________________

  // function for checking the location service and change button icon
  void serviceCheckTimer() {
    timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      setState(() {
        serviceIconEnabled = serviceEnabled;
      });
    });
  }

  //_________________________________________

  @override
  void dispose() {
    _alignPositionStreamController.close();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FlutterMap(
          options: MapOptions(
            initialCenter: cairoCenter,

            // Center the map over London
            initialZoom: 15,
            onTap: (tapPosition, point) {
              if (isAddingMarker) {
                setState(() {
                  newMarkerPosition = point;
                });
              }
            },
            // stops auto center when moving map screen
            onPositionChanged: (MapCamera camera, bool hasGesture) {
              if (hasGesture && _alignPositionOnUpdate != AlignOnUpdate.never) {
                setState(() => _alignPositionOnUpdate = AlignOnUpdate.never);
              }
            },
          ),
          children: [
            TileLayer(
              // Bring your own tiles
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // For demonstration only
              userAgentPackageName:
                  'com.example.mymap', // Add your app identifier
            ),

            MarkerLayer(
              markers: [
                ...markers,
                if (newMarkerPosition != null)
                  Marker(
                    point: newMarkerPosition!,
                    width: 40,
                    height: 40,
                    child: Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
              ],
            ),

            CurrentLocationLayer(
              alignPositionStream: _alignPositionStreamController.stream,
              alignPositionOnUpdate: _alignPositionOnUpdate,
              positionStream: _positionStream,
            ),

            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.white70,
                  shape: CircleBorder(),
                  onPressed: () async {
                    bool serviceEnabled =
                        await Geolocator.isLocationServiceEnabled();

                    if (!serviceEnabled) {
                      try {
                        await Geolocator.getCurrentPosition();
                      } catch (_) {}
                    }
                    // Align the location marker to the center of the map widget
                    // on location update until user interact with the map.
                    setState(
                      () => _alignPositionOnUpdate = AlignOnUpdate.always,
                    );
                    // Align the location marker to the center of the map widget
                    // and zoom the map to level 18.
                    _alignPositionStreamController.add(16);
                  },

                  child: Icon(
                    serviceIconEnabled
                        ? Icons.my_location
                        : Icons.location_disabled,
                  ),
                  // child: Icon(Icons.my_location),
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isAddingMarker)
                      FloatingActionButton(
                        heroTag: 'confirm',
                        backgroundColor: Colors.green,
                        child: Icon(Icons.check),
                        onPressed: () {
                          if (newMarkerPosition != null) {
                            setState(() {
                              markers.add(
                                Marker(
                                  point: newMarkerPosition!,
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.blue,
                                  ),
                                ),
                              );
                              newMarkerPosition = null;
                              isAddingMarker = false;
                            });
                          }
                        },
                      ),
                    if (isAddingMarker) const SizedBox(height: 10),
                    if (isAddingMarker)
                      FloatingActionButton(
                        heroTag: 'cancel',
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            isAddingMarker = false;
                            newMarkerPosition = null;
                          });
                        },
                      ),
                    const SizedBox(height: 10),
                    FloatingActionButton(
                      heroTag: 'add',
                      child: Icon(Icons.add_location_alt),
                      onPressed: () {
                        setState(() {
                          isAddingMarker = true;
                          newMarkerPosition = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            FloatingSearch(),
          ],
        ),
      ),
    );
  }
}
