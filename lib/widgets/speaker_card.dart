import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/language.dart';

class SpeakerCard extends StatelessWidget {
  final int speakerNumber;
  final Language language;
  final String gender;
  final String text;
  final String translatedText;
  final bool isRecording;
  final Function(Language) onLanguageChanged;
  final Function(String) onGenderChanged;
  final VoidCallback onRecordPressed;

  const SpeakerCard({
    super.key,
    required this.speakerNumber,
    required this.language,
    required this.gender,
    required this.text,
    required this.translatedText,
    required this.isRecording,
    required this.onLanguageChanged,
    required this.onGenderChanged,
    required this.onRecordPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1F3A).withOpacity(0.8),
            const Color(0xFF1A1F3A).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isRecording 
              ? const Color(0xFFFF6B35).withOpacity(0.8)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: isRecording
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'SPEAKER $speakerNumber',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              _buildGenderToggle(),
            ],
          ),
          const SizedBox(height: 15),

          // Language Selector
          _buildLanguageSelector(context),
          
          const SizedBox(height: 15),

          // Text Display
          Expanded(
            child: _buildTextDisplay(),
          ),

          const SizedBox(height: 15),

          // Microphone Button
          _buildMicrophoneButton(),
        ],
      ),
    ).animate(
      target: isRecording ? 1 : 0,
    ).scale(
      duration: 200.ms,
      begin: const Offset(1, 1),
      end: const Offset(1.02, 1.02),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLanguagePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E27).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Text(
              language.flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Text(
              language.nativeName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E27).withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildGenderOption('Male', Icons.male, gender == 'male'),
          const SizedBox(width: 4),
          _buildGenderOption('Female', Icons.female, gender == 'female'),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => onGenderChanged(label.toLowerCase()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF6B35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextDisplay() {
    final displayText = text.isNotEmpty ? text : language.nativeName;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E27).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 16,
            color: text.isNotEmpty 
                ? Colors.white 
                : Colors.white.withOpacity(0.3),
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMicrophoneButton() {
    return Center(
      child: GestureDetector(
        onTap: onRecordPressed,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isRecording
                ? const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF5252)],
                  )
                : LinearGradient(
                    colors: [
                      const Color(0xFF4ECDC4),
                      const Color(0xFF44A08D),
                    ],
                  ),
            boxShadow: [
              BoxShadow(
                color: (isRecording 
                    ? const Color(0xFFFF6B35) 
                    : const Color(0xFF4ECDC4)).withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: isRecording ? 5 : 0,
              ),
            ],
          ),
          child: Icon(
            isRecording ? Icons.stop_rounded : Icons.mic_rounded,
            color: Colors.white,
            size: 32,
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(),
        ).shimmer(
          duration: 2000.ms,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Select Language',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: Language.allLanguages.length,
                  itemBuilder: (context, index) {
                    final lang = Language.allLanguages[index];
                    final isSelected = lang.code == language.code;
                    
                    return ListTile(
                      leading: Text(
                        lang.flag,
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(
                        lang.nativeName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        lang.name,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Color(0xFF4ECDC4))
                          : null,
                      onTap: () {
                        onLanguageChanged(lang);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
