import 'dart:math';
import 'package:flutter/material.dart';

/// A customizable spinning wheel widget for random selection.
///
/// The wheel displays a list of [SpinWheelItem]s as colored segments.
/// When tapped, it spins with a realistic deceleration animation and
/// highlights the selected segment before returning the result.
class SpinWheel extends StatefulWidget {
  /// List of items to display on the wheel segments.
  final List<SpinWheelItem> items;

  /// Callback function called when the wheel stops spinning.
  /// Returns the selected [SpinWheelItem].
  final Function(SpinWheelItem) onResult;

  /// Size of the wheel (width and height). Defaults to 300.
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
  // Animation controller for the spinning motion
  late AnimationController _spinController;

  // Animation controller for the highlight effect after selection
  late AnimationController _highlightController;

  late Animation<double> _spinAnimation;
  late Animation<double> _highlightAnimation;

  // Current rotation angle in radians
  double _currentRotation = 0;

  // Whether the wheel is currently spinning
  bool _isSpinning = false;

  // Index of the selected item (null until wheel stops)
  int? _selectedIndex;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Spin animation: 4 seconds with easeOutCubic for realistic deceleration
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // Highlight animation: 800ms pulse effect
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

  /// Initiates the spin animation.
  ///
  /// Generates a random rotation amount (3-5 full rotations + random extra)
  /// and animates the wheel with easeOutCubic curve for realistic deceleration.
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
      // Calculate which segment is under the pointer
      final segmentAngle = 2 * pi / widget.items.length;
      final normalizedRotation = _currentRotation % (2 * pi);
      final n = widget.items.length;

      // The wheel rotates clockwise (positive angle in Flutter).
      // Segments are drawn clockwise from top: 0, 1, 2, ...
      // Formula accounts for rotation direction and segment positioning.
      int selectedIndex = (n - (normalizedRotation / segmentAngle).floor() - 1 + n) % n;

      setState(() {
        _isSpinning = false;
        _selectedIndex = selectedIndex;
      });

      // Play highlight animation, then return result after a short delay
      _highlightController.forward(from: 0).then((_) {
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
        // Triangular pointer at the top indicating selection position
        CustomPaint(
          size: const Size(30, 20),
          painter: _PointerPainter(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        // The wheel itself
        GestureDetector(
          onTap: _spin,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating wheel with segments
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

                // Center "SPIN" button
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

        // Status text: shows instructions or selected item
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

/// Custom painter that draws the wheel segments.
///
/// Each segment is drawn as a colored arc with text label.
/// The selected segment (if any) gets highlight effects:
/// - Pulse (grows outward)
/// - Glow (white border blur)
/// - Brighten (color becomes lighter)
class _WheelPainter extends CustomPainter {
  final List<SpinWheelItem> items;
  final int? selectedIndex;
  final double highlightProgress; // 0.0 to 1.0

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
      // Start angle offset by -pi/2 so first segment is at top
      final startAngle = i * segmentAngle - pi / 2;
      final isSelected = i == selectedIndex && highlightProgress > 0;

      // Calculate highlight effects for selected segment
      double segmentRadius = radius;
      Color segmentColor = items[i].color;

      if (isSelected) {
        // Pulse effect: segment grows outward using sine wave
        final pulse = sin(highlightProgress * pi) * 8;
        segmentRadius = radius + pulse;

        // Brighten effect: blend color towards white
        final brightness = (sin(highlightProgress * pi) * 0.3).clamp(0.0, 1.0);
        segmentColor = Color.lerp(items[i].color, Colors.white, brightness)!;
      }

      // Draw filled segment
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

      // Draw glow effect for selected segment
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

      // Draw segment border
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

      // Draw text label at segment center
      final textAngle = startAngle + segmentAngle / 2;
      final textRadius = (isSelected ? segmentRadius : radius) * 0.65;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + pi / 2); // Rotate text to be readable

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

  /// Returns black or white depending on background color luminance.
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

/// Custom painter for the triangular pointer above the wheel.
class _PointerPainter extends CustomPainter {
  final Color color;

  _PointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw downward-pointing triangle
    final path = Path()
      ..moveTo(size.width / 2, size.height) // Bottom center point
      ..lineTo(0, 0)                         // Top left
      ..lineTo(size.width, 0)                // Top right
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Represents an item on the spin wheel.
class SpinWheelItem {
  /// Display text shown on the wheel segment.
  final String label;

  /// Internal value used for selection logic.
  final String value;

  /// Background color of the segment.
  final Color color;

  /// Optional icon (not currently used in wheel display).
  final IconData? icon;

  const SpinWheelItem({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });
}

/// Predefined color palette for wheel segments.
///
/// Provides visually distinct, vibrant colors that work well together.
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

  /// Returns a color from the palette, cycling if index exceeds palette length.
  static Color getColor(int index) {
    return palette[index % palette.length];
  }
}
