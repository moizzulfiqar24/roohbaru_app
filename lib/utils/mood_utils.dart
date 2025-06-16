import 'package:flutter/material.dart';

/// Default background color when no mood match is found.
const Color defaultMoodBackground = Color(0xFFf8eed5);

/// Map from mood string → background color.
const Map<String, Color> moodBackgroundColors = {
  'Happy': Color(0xFFAADAF0),
  'Excited': Color(0xFFD6D3F9),
  'Calm': Color(0xFF7FD1AE),
  'Grateful': Color(0xFFF1DEAC),
  'Loving': Color(0xFFF5C8CB),
  'Confident': Color(0xFFFFC5A6),
  'Sad': Color(0xFFF5C8CB),
  'Angry': Color(0xFFFFC5A6),
  'Anxious': Color(0xFFD6D3F9),
  'Lonely': Color(0xFFAADAF0),
  'Guilty': Color(0xFFF1DEAC),
  'Jealous': Color(0xFF7FD1AE),
  'Confused': Color(0xFFD6D3F9),
  'Surprised': Color(0xFFAADAF0),
  'Bored': Color(0xFFF1DEAC),
  'Restless': Color(0xFFFFC5A6),
  'Inspired': Color(0xFF7FD1AE),
  'Distracted': Color(0xFFD6D3F9),
};
