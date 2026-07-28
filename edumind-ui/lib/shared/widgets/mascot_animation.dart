import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MascotAnimation extends StatelessWidget {
  final String name; // e.g., 'happy', 'idle2'
  final double height;
  final bool repeat;

  const MascotAnimation({
    super.key,
    required this.name,
    this.height = 140,
    this.repeat = true,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/$name.lottie',
      height: height,
      repeat: repeat,
      fit: BoxFit.contain,
    );
  }
}