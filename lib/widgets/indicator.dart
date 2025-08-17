import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import 'package:gaimon/gaimon.dart';
import 'animated_gradient_background.dart';

class LoadingIndicator extends StatefulWidget {
  final String message;
  final List<Color> colors;

  const LoadingIndicator({
    Key? key,
    required this.message,
    required this.colors,
  }) : super(key: key);

  @override
  _LoadingIndicatorState createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String displayText = '';
  bool _disposed = false;
  Timer? _hapticTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _animateText();
    _playHapticPattern();

    _hapticTimer = Timer.periodic(Duration(seconds: 3), (_) {
      _playHapticPattern();
    });
  }

  void _animateText() async {
    for (int i = 0; i < widget.message.length; i++) {
      if (_disposed) return;
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() {
        displayText = widget.message.substring(0, i + 1);
      });
    }
  }

  void _playHapticPattern() async {
    try {
      final String response = 
      await rootBundle.loadString('assets/Gravel.ahap');
      Gaimon.patternFromData(response);
    } catch (e) {
      print('Error playing haptic pattern: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.dispose();
    _hapticTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      colors: widget.colors,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: PulsatingOrbitPainter(
                  animation: _controller,
                  color: Colors.white,
                ),
                size: Size.infinite,
              );
            },
          ),
          Center(
            child: Text(
              displayText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black.withOpacity(0.3),
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PulsatingOrbitPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  PulsatingOrbitPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 3;

    final particlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = 2 * pi * (i / 12 + animation.value);
      final orbitRadius = maxRadius * 1.2;
      final x = center.dx + orbitRadius * cos(angle);
      final y = center.dy + orbitRadius * sin(angle);

      final particleRadius =
          5.0 + 3.0 * sin((animation.value + i / 12) * 2 * pi);
      canvas.drawCircle(Offset(x, y), particleRadius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
