import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quickalert/quickalert.dart';

class GeoL {
  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position?> determinePosition(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;
    Position? position;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {}

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          await showdialogWg1(context);
        }
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      if (context.mounted) {
        await showdialogWg2(context);
      }
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      try {
        position = await Geolocator.getCurrentPosition();
      } catch (_) {}
    }

    return position;
  }
}

Future<void> showdialogWg1(BuildContext context) async {
  return await QuickAlert.show(
    animType: QuickAlertAnimType.slideInUp,
    context: context,
    type: QuickAlertType.warning,
    text: 'Please allow location permission to use the app.',
    confirmBtnText: "Allow",
    barrierDismissible: false,

    onConfirmBtnTap: () async {
      Navigator.of(context).pop(); // close dialog
      await Geolocator.requestPermission();
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        try {
          await Geolocator.getCurrentPosition();
        } catch (_) {}
      }
    },

    showCancelBtn: true,
    onCancelBtnTap: () {
      Navigator.pop(context);
    },
  );
}

Future<void> showdialogWg2(BuildContext context) async {
  return await QuickAlert.show(
    context: context,
    barrierDismissible: false,
    type: QuickAlertType.error,
    title: "Warning",
    text: 'Please Enable location permission to use the app.',
    confirmBtnText: "Settings",

    onConfirmBtnTap: () async {
      Navigator.of(context).pop(); // close dialog
      await Geolocator.openAppSettings();
    },

    showCancelBtn: true,
    onCancelBtnTap: () {
      SystemNavigator.pop();
    },
    cancelBtnText: "exit",
  );
}
