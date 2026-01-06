import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LanguageSwapButton extends StatelessWidget {
  final VoidCallback onTap;

  const LanguageSwapButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4ECDC4).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.swap_vert_rounded,
          color: Colors.white,
          size: 30,
        ),
      )
          .animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          )
          .rotate(
            duration: 1000.ms,
            begin: 0,
            end: 0.5,
          )
          .then()
          .rotate(
            duration: 1000.ms,
            begin: 0.5,
            end: 1,
          ),
    );
  }
}
