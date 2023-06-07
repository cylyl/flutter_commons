import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:flustars/flustars.dart';

class DeviceInfo {

  static final String keyGuid = "guid";

  static Future<String> udid() async {
    return await FlutterUdid.udid;
  }

  static Future<String?> uuid() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String? guid;
    try {
      if (kIsWeb) {
        await SpUtil.getInstance();

        guid = SpUtil.getString(keyGuid);
        if(guid == null || guid.isEmpty) {
          guid = genUuid();
          SpUtil.putString(keyGuid, guid);
        }
      } else {
        if (Platform.isAndroid) {
          guid = (await deviceInfoPlugin.androidInfo).serialNumber;
        } else if (Platform.isIOS) {
          guid = (await deviceInfoPlugin.iosInfo).identifierForVendor;
        } else if (Platform.isLinux) {
          guid = (await deviceInfoPlugin.linuxInfo).machineId;
        } else if (Platform.isMacOS) {
          MacOsDeviceInfo macOsDeviceInfo = (await deviceInfoPlugin.macOsInfo);
          guid = macOsDeviceInfo.computerName+macOsDeviceInfo.hostName;
        } else if (Platform.isWindows) {
          guid = (await deviceInfoPlugin.windowsInfo).computerName;
        }
      }
    } on PlatformException {
    }
    return guid;
  }


  static String genUuid() {
    return Uuid().v1();
  }
}