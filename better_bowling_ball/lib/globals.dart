import 'package:better_bowling_ball/bt_page.dart';
import 'package:better_bowling_ball/history/history_page.dart';
import 'package:better_bowling_ball/new_game_page.dart';
import 'package:better_bowling_ball/single_throw_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class GlobalData {
  static bool accessible = false;
  static FlutterBlue flutterBlue = FlutterBlue.instance;
  static List<List<int>> dataValues = [];
  static late BluetoothCharacteristic writeCharacteristic;

  static List<int> dataByteFixer(List<int> receivedData) {
    List<int> fixedData = [];

    if (receivedData.length < 16) {
      return fixedData;
    }

    int finalTimestamp = 0;
    for (int i = 0; i < 8; i++) {
      int shiftValue = i * 8;
      finalTimestamp += receivedData[i] << shiftValue;
    }
    fixedData.add(finalTimestamp);

    for (int i = 8; i < 20; i += 2) {
      int fixedMeasurement = 0;
      fixedMeasurement += receivedData[i];
      fixedMeasurement += receivedData[i + 1] << 8;
      fixedData.add(fixedMeasurement);
    }

    return fixedData;
  }
}
