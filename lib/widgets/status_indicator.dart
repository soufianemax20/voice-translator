import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslationProvider>(
      builder: (context, provider, _) {
        final isActive = provider.isTranslating || provider.isSpeaking;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F3A).withOpacity(0.6),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isActive 
                  ? const Color(0xFF4ECDC4).withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isActive)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4ECDC4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4ECDC4).withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              Text(
                provider.statusMessage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isActive 
                      ? const Color(0xFF4ECDC4)
                      : Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
