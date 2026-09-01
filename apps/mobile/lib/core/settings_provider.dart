import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/chroma_engine.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final quantityUnitProvider =
    StateProvider<QuantityUnit>((ref) => QuantityUnit.parts);
final highContrastProvider = StateProvider<bool>((ref) => false);
