// bubbles.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class BurstEffect {
  final Offset position;
  final double radius;
  final Color color;
  late AnimationController controller;
  late Animation<double> animation;
  List<BubbleFragment> fragments = [];
  List<Particle> particles = [];
  final TextStyle textStyle;

  BurstEffect({
    required this.position,
    required this.radius,
    required this.color,
    required TickerProvider vsync,
    required this.textStyle,
  }) {
    controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: vsync,
    );
    animation = CurvedAnimation(parent: controller, curve: Curves.easeOutQuad);

    // Generate particles
    final particleCount = 200;
    for (int i = 0; i < particleCount; i++) {
      particles.add(Particle(
        position: position,
        color: color,
        angle: math.Random().nextDouble() * 2 * math.pi,
        speed: math.Random().nextDouble() * 15 + 7.5,
        size: math.Random().nextDouble() * 6 + 2,
      ));
    }
  }
}

class Bubble {
  final String ingredient;
  Offset position; // Current position
  Offset targetPosition; // Calculated target position
  Color color;

  Bubble(
      {required this.ingredient,
      required this.position,
      required this.targetPosition,
      required this.color});
}

class BubbleFragment {
  final Offset center;
  final double angle;
  final double radius;
  final Color color;
  double distance = 0;

  BubbleFragment({
    required this.center,
    required this.angle,
    required this.radius,
    required this.color,
  });

  void update(double progress) {
    distance = radius * progress * 2.5;
  }

  Path getPath(double progress) {
    final fragmentAngle = math.pi / 5;
    final path = Path();

    final startAngle = angle - fragmentAngle / 2;
    final endAngle = angle + fragmentAngle / 2;

    final outerRadius = radius + distance;
    final innerRadius = radius * (1 - progress * 0.8);

    path.addArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      startAngle,
      fragmentAngle,
    );

    path.arcTo(
      Rect.fromCircle(center: center, radius: innerRadius),
      endAngle,
      -fragmentAngle,
      false,
    );

    path.close();
    return path;
  }
}

class Particle {
  Offset position;
  Color color;
  double angle;
  double speed;
  double size;
  double opacity = 1.0;

  Particle({
    required this.position,
    required this.color,
    required this.angle,
    required this.speed,
    required this.size,
  });

  void update(double progress) {
    final distance = speed * progress * 0.1;
    position = Offset(
      position.dx + distance * math.cos(angle),
      position.dy + distance * math.sin(angle),
    );
    speed *= 0.997;
    size *= 0.998;
    opacity = 1.0 - progress;
  }
}

class BurstEffectWidget extends StatelessWidget {
  final BurstEffect effect;

  BurstEffectWidget({required this.effect});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: effect.animation,
      builder: (context, child) {
        return CustomPaint(
          painter: BurstPainter(
            effect: effect,
            progress: effect.animation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class BurstPainter extends CustomPainter {
  final BurstEffect effect;
  final double progress;

  BurstPainter({required this.effect, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in effect.particles) {
      particle.update(progress);
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SpherePainter extends CustomPainter {
  final Animation<double> animation;
  final List<Bubble> bubbles;
  final double transitionSpeed = 0.05; // Adjust for desired smoothness
  final TextStyle textStyle;

  SpherePainter({
    required this.animation,
    required this.bubbles,
    required this.textStyle,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Calculate target positions
    for (int i = 0; i < bubbles.length; i++) {
      final bubble = bubbles[i];
      final angle = 2 * math.pi * (i / bubbles.length + animation.value);
      final targetX = centerX + 150 * math.cos(angle);
      final targetY = centerY + 150 * math.sin(angle);
      bubble.targetPosition = Offset(targetX, targetY);
    }

    // Update bubble positions for smooth transition
    for (final bubble in bubbles) {
      bubble.position =
          Offset.lerp(bubble.position, bubble.targetPosition, transitionSpeed)!;
      _drawSphereWithIngredient(
          canvas,
          bubble.position.dx,
          bubble.position.dy,
          100, // Bubble radius
          bubble.ingredient,
          1.0, // Opacity
          bubble.color);
    }
  }

  void _drawSphereWithIngredient(Canvas canvas, double x, double y,
      double radius, String ingredient, double opacity, Color color) {
    final spherePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.8 * opacity),
          Colors.white.withOpacity(0.1 * opacity), // Subtler outer color
        ],
        stops: [0.2, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));

    canvas.drawCircle(Offset(x, y), radius, spherePaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.5 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final highlightPath = Path()
      ..addArc(
        Rect.fromCircle(
            center: Offset(x - radius * 0.2, y - radius * 0.2),
            radius: radius * 0.8),
        -math.pi / 4,
        math.pi / 2,
      );

    canvas.drawPath(highlightPath, highlightPaint);
    // --- End of Corrected Sphere Appearance ---

    final textSpan = TextSpan(
      text: ingredient,
      style: textStyle.copyWith(color: textStyle.color!.withOpacity(opacity)),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(maxWidth: radius * 1.5);
    final textX = x - textPainter.width / 2;
    final textY = y - textPainter.height / 2;

    textPainter.paint(canvas, Offset(textX, textY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BubbleManager {
  final List<Bubble> bubbles; // Now uses the Bubble class
  final Function(int) onBubbleBurst;
  final BuildContext context;
  final TickerProvider vsync;
  final Function(BurstEffect) addBurstEffect;

  BubbleManager({
    required this.bubbles,
    required this.onBubbleBurst,
    required this.context,
    required this.vsync,
    required this.addBurstEffect,
  });

  void onTapDown(
      TapDownDetails details, Size size, Animation<double> animation) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < bubbles.length; i++) {
      final bubble = bubbles[i];
      final angle = 2 * math.pi * (i / bubbles.length + animation.value);
      final x = centerX + 150 * math.cos(angle);
      final y = centerY + 150 * math.sin(angle);

      if ((Offset(x, y) - localPosition).distance < 50) {
        burstBubble(i, Offset(x, y), bubble.color);
        break;
      }
    }
  }

  void burstBubble(int index, Offset position, Color color) async {
    await HapticFeedback.mediumImpact();

    final burstEffect = BurstEffect(
      position: position,
      radius: 50,
      color: color, // Use the bubble's color
      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
      vsync: vsync,
    );

    addBurstEffect(burstEffect);
    onBubbleBurst(index);
    burstEffect.controller.forward().then((_) {
      burstEffect.controller.dispose();
    });
  }

  Color getBubbleColor(String ingredient) {
    int hash = ingredient.toLowerCase().codeUnits.reduce((a, b) => a + b);
    final List<Color> pastelColors = [
      Color.fromRGBO(229, 229, 248, 1),
      Color.fromRGBO(206, 217, 247, 1),
      Color.fromRGBO(156, 185, 249, 1),
      Color.fromRGBO(107, 157, 251, 1),
      Color.fromRGBO(69, 136, 255, 1),
      Color.fromRGBO(60, 130, 254, 1),
      Color.fromRGBO(35, 127, 251, 1),
      Color.fromRGBO(61, 120, 251, 1),
      Color.fromRGBO(61, 110, 250, 1),
      Color.fromRGBO(57, 88, 247, 1),
      Color.fromRGBO(50, 64, 241, 1),
      Color.fromRGBO(43, 50, 231, 1),
      Color.fromRGBO(65, 66, 228, 1),
      Color.fromRGBO(128, 128, 232, 1),
      Color.fromRGBO(191, 189, 240, 1),
    ];
    return pastelColors[hash % pastelColors.length];
  }
}
