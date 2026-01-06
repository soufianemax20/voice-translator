import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import 'dart:math' as math;

class WaveformVisualizer extends StatelessWidget {
  const WaveformVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        final waveformData = audioProvider.waveformData;
        
        if (waveformData.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              math.min(waveformData.length, 50),
              (index) {
                final height = waveformData[index] * 80;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 3,
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFFF6B35),
                        const Color(0xFFFF6B35).withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
