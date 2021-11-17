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
}
