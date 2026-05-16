import 'dart:ui';
import 'package:flutter_riverpod/legacy.dart';

/**
 * Language Provider.
 * Stores the currently selected app locale.
 */
final languageProvider = StateProvider<Locale?>((ref) => null);
