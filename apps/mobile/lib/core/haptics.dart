import 'package:flutter/services.dart';

/// Light haptic feedback for mixing interactions.
void hapticSelect() => HapticFeedback.selectionClick();

void hapticLight() => HapticFeedback.lightImpact();

void hapticMedium() => HapticFeedback.mediumImpact();
