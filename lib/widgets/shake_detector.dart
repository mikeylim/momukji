import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onShake;
  final double shakeThreshold;
  final int shakeCountThreshold;
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
  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime? _lastShakeTime;
  int _shakeCount = 0;
  double _lastX = 0;
  double _lastY = 0;
  double _lastZ = 0;
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

  void _startListening() {
    _subscription = accelerometerEventStream().listen((event) {
      if (_isFirstReading) {
        _lastX = event.x;
        _lastY = event.y;
        _lastZ = event.z;
        _isFirstReading = false;
        return;
      }

      final double deltaX = (event.x - _lastX).abs();
      final double deltaY = (event.y - _lastY).abs();
      final double deltaZ = (event.z - _lastZ).abs();

      final double acceleration = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);

      if (acceleration > widget.shakeThreshold) {
        final now = DateTime.now();

        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!) > widget.shakeDuration) {
          _shakeCount = 1;
        } else {
          _shakeCount++;
        }

        _lastShakeTime = now;

        if (_shakeCount >= widget.shakeCountThreshold) {
          _shakeCount = 0;
          _lastShakeTime = null;
          widget.onShake();
        }
      }

      _lastX = event.x;
      _lastY = event.y;
      _lastZ = event.z;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
