import 'package:flutter/material.dart';

class AppAnimations {
  // Durations
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
  static const extraSlow = Duration(milliseconds: 800);

  // Curves
  static const curve = Curves.easeOutCubic;
  static const emphasize = Curves.easeOutQuart;
  static const elastic = Curves.easeOutBack;

  // Standard Tweens
  static final fade = Tween<double>(begin: 0.0, end: 1.0);
  static final scale = Tween<double>(begin: 0.95, end: 1.0);
  static final slideUp = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero);
}
