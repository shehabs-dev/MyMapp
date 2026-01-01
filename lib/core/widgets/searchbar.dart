import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

class FloatingSearch extends StatefulWidget {
  const FloatingSearch({super.key});

  @override
  State<FloatingSearch> createState() => _FloatingSearchState();
}

class _FloatingSearchState extends State<FloatingSearch> {
  @override
  void dispose() {
    textListner.close();
    super.dispose();
  }

  FloatingSearchBarController textListner = FloatingSearchBarController();
  Future<List<Map<String, dynamic>>>? results;
  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return FloatingSearchBar(
      hint: 'Search...',
      controller: textListner,
      borderRadius: BorderRadius.all(Radius.circular(20)).r,
      scrollPadding: const EdgeInsets.only(top: 5, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        setState(() {
          results = searchPlaces(textListner.query);
        });
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(showIfClosed: false),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: FutureBuilder(
              future: results,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
                } else if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isNotEmpty) {
                  return SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          shape: Border(bottom: BorderSide(width: 0.2)),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data![index]['country'] ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data![index]['formatted'] ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                snapshot.data![index]['state'] ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.location_on_rounded,
                            color: Colors.deepPurple,
                          ),
                          onTap: () {},
                        );
                      },
                    ),
                  );
                }
                return Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0).r,
                    child: Text(
                      "No Results Found",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
  // Returns decoded JSON. Or you can return http.Response if you need statusCode, headers, etc.
  final response = await get(
    Uri.parse(
      'https://api.geoapify.com/v1/geocode/autocomplete?text=$query&lang=en&limit=10&apiKey=aa18b6439ef04da6a92d104be04dcdbf',
    ),
  );
  final responseBody = jsonDecode(response.body);
  final features = responseBody['features'] as List;
  return features.map((e) => e['properties'] as Map<String, dynamic>).toList();
}
