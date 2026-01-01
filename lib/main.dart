// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mymap/core/theme/themedata/themedata_light.dart';
import 'package:mymap/core/widgets/flutter_map.dart';
import 'package:mymap/home_page.dart';

class NavigatorPage extends StatelessWidget {
  const NavigatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,

      builder: (context, child) => MaterialApp(
        theme: getLightTheme(),
        debugShowCheckedModeBanner: false,

        initialRoute: '/',
        routes: {'/': (context) => HomePage(), 'Map': (context) => MapViewer()},
      ),
    );
  }
}

void main() => runApp(NavigatorPage());
