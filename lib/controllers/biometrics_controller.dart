import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricsController extends GetxController {
  final LocalAuthentication auth = LocalAuthentication();
  late bool canCheckBiometrics;
  Rx<bool> isBiometricEnabled = false.obs;
  final SharedPreferencesWithCache prefs = Get.find();

  Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to show account balance');
      return didAuthenticate;
      // ···
    } on PlatformException catch (e) {
      // ...
      log('Error: $e');
      return false;
    }
  }

  Future<void> initialize() async {
    canCheckBiometrics = await auth.canCheckBiometrics;
    isBiometricEnabled.value = prefs.getBool('biometricEnabled') ?? false;
  }

  void toggleBiometric(bool newValue) {
    isBiometricEnabled.value = newValue;
    prefs.setBool('biometricEnabled', newValue);
  }
}
