import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'core/services/location_handling.dart';
import 'core/widgets/flutter_map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GeoL checkPermission = GeoL();
  Position? position;
  bool permissionDenied = false;
  bool isLoading = true;
  Position? savedPos;
  bool isRetry = false;
  late Future<Position?> _permissionFuture;

  @override
  void initState() {
    super.initState();
    _permissionFuture = _checkPermission();
  }

  Future<Position?> _checkPermission() async {
    try {
      position = await checkPermission.determinePosition(context);
    } catch (_) {}

    return position;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _permissionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: LottieBuilder.asset('assets/animation/Globe.json'),
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return MapViewer();
        } else {
          return Scaffold(
            body: SafeArea(
              child: SizedBox.expand(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Somthing went wrong!",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    LottieBuilder.asset('assets/animation/no place.json'),
                    Text(
                      "We couldn't find your location :(",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 50.h),
                    ElevatedButton(
                      onPressed: () {
                        _permissionFuture = _checkPermission();
                        setState(() {
                          if (snapshot.hasData && snapshot.data != null) {
                            Navigator.pushReplacementNamed(context, 'Map');
                          }
                        });
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  } // fallback
}
