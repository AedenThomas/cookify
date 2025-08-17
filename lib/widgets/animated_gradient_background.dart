import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class AnimatedGradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final double speed;
  final double frequency;
  final double amplitude;

  const AnimatedGradientBackground({
    Key? key,
    required this.child,
    required this.colors,
    this.speed = 1.4,
    this.frequency = 0.6,
    this.amplitude = 3.0,
  })  : assert(colors.length == 4, 'Exactly four colors must be provided.'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedMeshGradient(
          colors: colors,
          options: AnimatedMeshGradientOptions(
            speed: speed,
            frequency: frequency,
            amplitude: amplitude,
          ),
        ),
        child,
      ],
    );
  }
}
