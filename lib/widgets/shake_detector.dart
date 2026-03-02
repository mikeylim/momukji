import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// A widget that detects device shake gestures and triggers a callback.
///
/// Wraps a child widget and listens to accelerometer events to detect
/// shake motions. When sufficient shakes are detected within the specified
/// duration, the [onShake] callback is invoked.
///
/// Example usage:
/// ```dart
/// ShakeDetector(
///   onShake: () => print('Device shaken!'),
///   child: MyWidget(),
/// )
/// ```
class ShakeDetector extends StatefulWidget {
  /// The widget to wrap with shake detection capability.
  final Widget child;

  /// Callback function invoked when a shake gesture is detected.
  final VoidCallback onShake;

  /// Minimum acceleration change required to register as a shake.
  /// Higher values require more forceful shakes. Defaults to 15.0.
  final double shakeThreshold;

  /// Number of consecutive shakes required to trigger [onShake].
  /// Defaults to 3 shakes.
  final int shakeCountThreshold;

  /// Maximum time window for counting consecutive shakes.
  /// Shakes outside this window reset the counter. Defaults to 500ms.
  final Duration shakeDuration;

  const ShakeDetector({
    super.key,
    required this.child,
    required this.onShake,
    this.shakeThreshold = 15.0,
    this.shakeCountThreshold = 3,
    this.shakeDuration = const Duration(milliseconds: 500),
  });

  @override
  State<ShakeDetector> createState() => _ShakeDetectorState();
}

class _ShakeDetectorState extends State<ShakeDetector> {
  /// Subscription to the accelerometer event stream.
  StreamSubscription<AccelerometerEvent>? _subscription;

  /// Timestamp of the last detected shake motion.
  DateTime? _lastShakeTime;

  /// Counter for consecutive shakes within the time window.
  int _shakeCount = 0;

  // Previous accelerometer readings for calculating delta
  double _lastX = 0;
  double _lastY = 0;
  double _lastZ = 0;

  /// Flag to skip the first reading (used to initialize previous values).
  bool _isFirstReading = true;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Starts listening to accelerometer events.
  ///
  /// Calculates the magnitude of acceleration change between readings
  /// using the Euclidean distance formula:
  /// √(Δx² + Δy² + Δz²)
  ///
  /// When acceleration exceeds [shakeThreshold], increments shake counter.
  /// If [shakeCountThreshold] is reached within [shakeDuration], triggers callback.
  void _startListening() {
    _subscription = accelerometerEventStream().listen((event) {
      // Skip first reading to initialize previous values
      if (_isFirstReading) {
        _lastX = event.x;
        _lastY = event.y;
        _lastZ = event.z;
        _isFirstReading = false;
        return;
      }

      // Calculate change in acceleration for each axis
      final double deltaX = (event.x - _lastX).abs();
      final double deltaY = (event.y - _lastY).abs();
      final double deltaZ = (event.z - _lastZ).abs();

      // Calculate total acceleration magnitude using Euclidean distance
      final double acceleration = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);

      // Check if acceleration exceeds shake threshold
      if (acceleration > widget.shakeThreshold) {
        final now = DateTime.now();

        // Reset counter if too much time has passed since last shake
        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!) > widget.shakeDuration) {
          _shakeCount = 1;
        } else {
          _shakeCount++;
        }

        _lastShakeTime = now;

        // Trigger callback if shake count threshold is reached
        if (_shakeCount >= widget.shakeCountThreshold) {
          _shakeCount = 0;
          _lastShakeTime = null;
          widget.onShake();
        }
      }

      // Store current readings for next comparison
      _lastX = event.x;
      _lastY = event.y;
      _lastZ = event.z;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ShakeDetector is transparent - just returns the child widget
    return widget.child;
  }
}
