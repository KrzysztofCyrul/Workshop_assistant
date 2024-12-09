import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SegmentColors {
  static Color segmentA = Color.fromARGB(255, 235, 199, 0);
  static Color segmentB = const Color.fromARGB(255, 33, 243, 79);
  static Color segmentC = Color.fromARGB(255, 90, 181, 255);
  static Color segmentD = Color.fromARGB(255, 161, 11, 0);
  static Color defaultColor = Colors.grey;

  static Future<void> loadColors() async {
    final prefs = await SharedPreferences.getInstance();
    segmentA = Color(prefs.getInt('segmentA') ?? segmentA.value);
    segmentB = Color(prefs.getInt('segmentB') ?? segmentB.value);
    segmentC = Color(prefs.getInt('segmentC') ?? segmentC.value);
    segmentD = Color(prefs.getInt('segmentD') ?? segmentD.value);
  }

  static Future<void> saveColors() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('segmentA', segmentA.value);
    prefs.setInt('segmentB', segmentB.value);
    prefs.setInt('segmentC', segmentC.value);
    prefs.setInt('segmentD', segmentD.value);
  }

  static void updateColors({
    required Color segmentAColor,
    required Color segmentBColor,
    required Color segmentCColor,
    required Color segmentDColor,
  }) {
    segmentA = segmentAColor;
    segmentB = segmentBColor;
    segmentC = segmentCColor;
    segmentD = segmentDColor;
  }
}
