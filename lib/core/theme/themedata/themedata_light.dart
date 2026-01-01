import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

ThemeData getLightTheme() => ThemeData(
  useMaterial3: true,

  textTheme: TextTheme(
    bodyLarge: TextStyle(
      fontSize: 20.sp,
      fontFamily: 'TikTokSans',
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle(fontSize: 16.sp),
  ),
);
