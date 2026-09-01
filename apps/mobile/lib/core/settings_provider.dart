import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final quantityUnitProvider = StateProvider<String>((ref) => 'parts');
final highContrastProvider = StateProvider<bool>((ref) => false);
