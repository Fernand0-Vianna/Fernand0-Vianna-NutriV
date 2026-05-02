import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

enum HapticType {
  light,
  medium,
  heavy,
  selection,
  success,
  warning,
  error,
}

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _isEnabled = true;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  Future<void> light() async {
    if (!_isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> medium() async {
    if (!_isEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> heavy() async {
    if (!_isEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> selection() async {
    if (!_isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  Future<void> success() async {
    if (!_isEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  Future<void> warning() async {
    if (!_isEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> error() async {
    if (!_isEnabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  Future<void> vibrate(HapticType type) async {
    switch (type) {
      case HapticType.light:
        await light();
        break;
      case HapticType.medium:
        await medium();
        break;
      case HapticType.heavy:
        await heavy();
        break;
      case HapticType.selection:
        await selection();
        break;
      case HapticType.success:
        await success();
        break;
      case HapticType.warning:
        await warning();
        break;
      case HapticType.error:
        await error();
        break;
    }

    if (kDebugMode) {
      debugPrint('Haptic: $type');
    }
  }
}