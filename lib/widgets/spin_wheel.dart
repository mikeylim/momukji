import 'dart:math';
import 'package:flutter/material.dart';

class SpinWheel extends StatefulWidget {
  final List<SpinWheelItem> items;
  final Function(SpinWheelItem) onResult;
  final double size;

  const SpinWheel({
    super.key,
    required this.items,
    required this.onResult,
    this.size = 300,
  });

  @override
  State<SpinWheel> createState() => _SpinWheelState();
}

class _SpinWheelState extends State<SpinWheel>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _highlightController;
  late Animation<double> _spinAnimation;
  late Animation<double> _highlightAnimation;
  double _currentRotation = 0;
  bool _isSpinning = false;
  int? _selectedIndex;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _highlightAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeInOut),
    );
    _highlightController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _highlightController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _selectedIndex = null;
    });

    // Random number of full rotations (3-5) plus random final position
    final fullRotations = 3 + _random.nextInt(3);
    final extraRotation = _random.nextDouble() * 2 * pi;
    final totalRotation = fullRotations * 2 * pi + extraRotation;

    _spinAnimation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation + totalRotation,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    ));

    _spinAnimation.addListener(() {
      setState(() {
        _currentRotation = _spinAnimation.value;
      });
    });

    _spinController.forward(from: 0).then((_) {
      // Calculate which item was selected
      final segmentAngle = 2 * pi / widget.items.length;
      final normalizedRotation = _currentRotation % (2 * pi);
      final n = widget.items.length;

      int selectedIndex = (n - (normalizedRotation / segmentAngle).floor() - 1 + n) % n;

      setState(() {
        _isSpinning = false;
        _selectedIndex = selectedIndex;
      });

      // Play highlight animation then return result
      _highlightController.forward(from: 0).then((_) {
        // Wait a moment to show the highlight
        Future.delayed(const Duration(milliseconds: 300), () {
          widget.onResult(widget.items[selectedIndex]);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pointer at the top
        CustomPaint(
          size: const Size(30, 20),
          painter: _PointerPainter(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        // The wheel
        GestureDetector(
          onTap: _spin,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Wheel segments
                Transform.rotate(
                  angle: _currentRotation,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _WheelPainter(
                      items: widget.items,
                      selectedIndex: _selectedIndex,
                      highlightProgress: _highlightAnimation.value,
                    ),
                  ),
                ),
                // Center button
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _isSpinning ? '...' : 'SPIN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Status text with selected item name
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _selectedIndex != null
              ? Text(
                  '🎉 ${widget.items[_selectedIndex!].label}!',
                  key: ValueKey(_selectedIndex),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Text(
                  _isSpinning ? 'Spinning...' : 'Tap the wheel to spin!',
                  key: ValueKey(_isSpinning),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
        ),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<SpinWheelItem> items;
  final int? selectedIndex;
  final double highlightProgress;

  _WheelPainter({
    required this.items,
    this.selectedIndex,
    this.highlightProgress = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / items.length;

    for (int i = 0; i < items.length; i++) {
      final startAngle = i * segmentAngle - pi / 2;
      final isSelected = i == selectedIndex && highlightProgress > 0;

      // Calculate highlight effect
      double segmentRadius = radius;
      Color segmentColor = items[i].color;

      if (isSelected) {
        // Pulse effect - segment grows slightly
        final pulse = sin(highlightProgress * pi) * 8;
        segmentRadius = radius + pulse;

        // Brighten the selected segment
        final brightness = (sin(highlightProgress * pi) * 0.3).clamp(0.0, 1.0);
        segmentColor = Color.lerp(items[i].color, Colors.white, brightness)!;
      }

      // Draw segment
      final paint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: segmentRadius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Draw glow for selected segment
      if (isSelected) {
        final glowPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.5 * sin(highlightProgress * pi))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: segmentRadius),
          startAngle,
          segmentAngle,
          true,
          glowPaint,
        );
      }

      // Draw border
      final borderPaint = Paint()
        ..color = isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 4 : 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: segmentRadius),
        startAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      // Draw text
      final textAngle = startAngle + segmentAngle / 2;
      final textRadius = (isSelected ? segmentRadius : radius) * 0.65;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + pi / 2);

      final textPainter = TextPainter(
        text: TextSpan(
          text: items[i].label,
          style: TextStyle(
            color: _getContrastColor(segmentColor),
            fontSize: isSelected ? 14 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(maxWidth: radius * 0.5);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }

    // Draw outer ring
    final outerRingPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius - 2, outerRingPaint);
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.highlightProgress != highlightProgress;
  }
}

class _PointerPainter extends CustomPainter {
  final Color color;

  _PointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SpinWheelItem {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  const SpinWheelItem({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });
}

// Predefined color palette for wheel segments
class WheelColors {
  static const List<Color> palette = [
    Color(0xFFE57373), // Red
    Color(0xFFFFB74D), // Orange
    Color(0xFFFFF176), // Yellow
    Color(0xFFAED581), // Light Green
    Color(0xFF4DB6AC), // Teal
    Color(0xFF64B5F6), // Blue
    Color(0xFF9575CD), // Purple
    Color(0xFFF06292), // Pink
    Color(0xFFFF8A65), // Deep Orange
    Color(0xFF81C784), // Green
    Color(0xFF4DD0E1), // Cyan
    Color(0xFFBA68C8), // Purple 2
  ];

  static Color getColor(int index) {
    return palette[index % palette.length];
  }
}
