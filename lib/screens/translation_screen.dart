import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/speaker_card.dart';
import '../widgets/language_swap_button.dart';
import '../widgets/waveform_visualizer.dart';
import '../widgets/status_indicator.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final audioProvider = context.read<AudioProvider>();
    await audioProvider.checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0E27),
              const Color(0xFF1A1F3A).withOpacity(0.8),
              const Color(0xFF0A0E27),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildMainContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // App Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.translate,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          // App Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VoiceTranslator',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Real-time AI Translation',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Settings button
          IconButton(
            onPressed: () {
              // TODO: Open settings
            },
            icon: Icon(
              Icons.settings_outlined,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Expanded(
      child: Column(
        children: [
          // Status Indicator
          const StatusIndicator(),
          const SizedBox(height: 30),

          // Waveform Visualizer
          Consumer<AudioProvider>(
            builder: (context, audioProvider, _) {
              if (audioProvider.isRecording) {
                return const WaveformVisualizer();
              }
              return _buildReadyState();
            },
          ),

          const SizedBox(height: 40),

          // Speaker Cards with Swap Button
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Speaker 1
                    Expanded(
                      child: Consumer<TranslationProvider>(
                        builder: (context, provider, _) {
                          return SpeakerCard(
                            speakerNumber: 1,
                            language: provider.speaker1Language,
                            gender: provider.speaker1Gender,
                            text: provider.speaker1Text,
                            translatedText: provider.speaker1TranslatedText,
                            isRecording: provider.speaker1IsRecording,
                            onLanguageChanged: provider.setSpeaker1Language,
                            onGenderChanged: provider.setSpeaker1Gender,
                            onRecordPressed: () => _handleRecording(1),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 80), // Space for swap button

                    // Speaker 2
                    Expanded(
                      child: Consumer<TranslationProvider>(
                        builder: (context, provider, _) {
                          return SpeakerCard(
                            speakerNumber: 2,
                            language: provider.speaker2Language,
                            gender: provider.speaker2Gender,
                            text: provider.speaker2Text,
                            translatedText: provider.speaker2TranslatedText,
                            isRecording: provider.speaker2IsRecording,
                            onLanguageChanged: provider.setSpeaker2Language,
                            onGenderChanged: provider.setSpeaker2Gender,
                            onRecordPressed: () => _handleRecording(2),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // Swap Button (centered between the two cards)
                Center(
                  child: LanguageSwapButton(
                    onTap: () {
                      context.read<TranslationProvider>().swapLanguages();
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReadyState() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4ECDC4).withOpacity(0.3),
                const Color(0xFF44A08D).withOpacity(0.3),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF4ECDC4).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.mic_none_rounded,
            size: 40,
            color: const Color(0xFF4ECDC4),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Ready to Translate',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select languages below and tap a\nmicrophone to start speaking.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Future<void> _handleRecording(int speakerNumber) async {
    final translationProvider = context.read<TranslationProvider>();
    final audioProvider = context.read<AudioProvider>();

    if (speakerNumber == 1) {
      if (translationProvider.speaker1IsRecording) {
        // Stop recording
        final audioBytes = await audioProvider.stopRecording();
        translationProvider.setSpeaker1Recording(false);
        
        if (audioBytes != null) {
          await translationProvider.processSpeaker1Audio(audioBytes);
        }
      } else {
        // Start recording
        final started = await audioProvider.startRecording();
        if (started) {
          translationProvider.setSpeaker1Recording(true);
        }
      }
    } else {
      if (translationProvider.speaker2IsRecording) {
        // Stop recording
        final audioBytes = await audioProvider.stopRecording();
        translationProvider.setSpeaker2Recording(false);
        
        if (audioBytes != null) {
          await translationProvider.processSpeaker2Audio(audioBytes);
        }
      } else {
        // Start recording
        final started = await audioProvider.startRecording();
        if (started) {
          translationProvider.setSpeaker2Recording(true);
        }
      }
    }
  }
}
