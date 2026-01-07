import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'services/mobile_audio_recorder.dart';
import 'services/scribe_v2_realtime.dart';
import 'services/aws_translate_service.dart';
import 'services/elevenlabs_service.dart';

void main() {
  runApp(const VoiceTranslatorApp());
}

class VoiceTranslatorApp extends StatelessWidget {
  const VoiceTranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neural Chat - VoiceTranslator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E2E),
      ),
      home: const TranslationScreen(),
    );
  }
}

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> with TickerProviderStateMixin {
  String selectedLang1 = 'Français';
  String selectedLang2 = 'English';
  bool isRecording1 = false;
  bool isRecording2 = false;
  String transcription1 = '';
  String transcription2 = '';
  
  late AnimationController _waveController;
  late AnimationController _pulseController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, String>> languages = [
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
    {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'hi', 'name': 'हिन्दी', 'flag': '🇮🇳'},
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  MobileAudioRecorder? _recorder1;
  MobileAudioRecorder? _recorder2;
  ScribeV2Service? _scribe1;
  ScribeV2Service? _scribe2;
  String? _lastTranscript1;
  String? _lastTranscript2;

  void toggleRecording1() async {
    setState(() {
      isRecording1 = !isRecording1;
    });

    if (isRecording1) {
      // Démarrer Scribe V2 Service
      _scribe1 = ScribeV2Service();
      _scribe1!.start(_getLangCode(selectedLang1));

      // Démarrer l'enregistrement
      _recorder1 = MobileAudioRecorder();
      final started = await _recorder1!.startRecording();
      
      if (!started) {
        setState(() {
          isRecording1 = false;
          transcription1 = '❌ Erreur: Microphone non accessible';
        });
        // _scribe1?.dispose(); // Ne pas fermer le stream ici
        return;
      }

      setState(() => transcription1 = '🎤 Écoute...');
      
      // Écouter les transcriptions
      _scribe1!.transcriptStream.listen((text) {
        setState(() => transcription1 = text);
        _lastTranscript1 = text;
      });
      
      // Envoyer les chunks audio
      _recorder1!.audioStream.listen((audioChunk) {
        _scribe1?.addAudioChunk(audioChunk);
      });
      
    } else {
      // Arrêter
      await _recorder1?.stopRecording();
      _scribe1?.stop();
      
      // Traduire
      if (_lastTranscript1 != null && _lastTranscript1!.isNotEmpty) {
        setState(() => transcription2 = '🔄 Traduction...');
        
        final translation = await AWSTranslateService.translate(
          text: _lastTranscript1!,
          sourceLang: _getLangCode(selectedLang1),
          targetLang: _getLangCode(selectedLang2),
        );
        
        if (translation != null) {
          setState(() => transcription2 = translation);
          
          final audioBytes = await ElevenLabsService.textToSpeech(
            text: translation,
            languageCode: _getLangCode(selectedLang2),
          );
          
          if (audioBytes != null) {
            _playAudio(audioBytes);
          }
        }
      }
      
      // _scribe1?.dispose(); // Le stream reste ouvert pour réutilisation
      _recorder1?.dispose();
    }
  }

  void toggleRecording2() async {
    setState(() {
      isRecording2 = !isRecording2;
    });

    if (isRecording2) {
      _scribe2 = ScribeV2Service();
      _scribe2!.start(_getLangCode(selectedLang2));

      _recorder2 = MobileAudioRecorder();
      final started = await _recorder2!.startRecording();
      
      if (!started) {
        setState(() {
          isRecording2 = false;
          transcription2 = '❌ Error: Microphone not accessible';
        });
        // _scribe2?.dispose(); // Ne pas fermer le stream
        return;
      }

      setState(() => transcription2 = '🎤 Listening...');
      
      _scribe2!.transcriptStream.listen((text) {
        setState(() => transcription2 = text);
        _lastTranscript2 = text;
      });
      
      _recorder2!.audioStream.listen((audioChunk) {
        _scribe2?.addAudioChunk(audioChunk);
      });
      
    } else {
      await _recorder2?.stopRecording();
      _scribe2?.stop();
      
      if (_lastTranscript2 != null && _lastTranscript2!.isNotEmpty) {
        setState(() => transcription1 = '🔄 Translating...');
        
        final translation = await AWSTranslateService.translate(
          text: _lastTranscript2!,
          sourceLang: _getLangCode(selectedLang2),
          targetLang: _getLangCode(selectedLang1),
        );
        
        if (translation != null) {
          setState(() => transcription1 = translation);
          
          final audioBytes = await ElevenLabsService.textToSpeech(
            text: translation,
            languageCode: _getLangCode(selectedLang1),
          );
          
          if (audioBytes != null) {
            _playAudio(audioBytes);
          }
        }
      }
      
      // _scribe2?.dispose(); // Le stream reste ouvert
      _recorder2?.dispose();
    }
  }

  String _getLangCode(String language) {
    final langMap = {
      'Français': 'fr',
      'English': 'en',
      'Español': 'es',
      'العربية': 'ar',
      'Deutsch': 'de',
      'Italiano': 'it',
      'Português': 'pt',
      '中文': 'zh',
      '日本語': 'ja',
      '한국어': 'ko',
      'Русский': 'ru',
      'हिन्दी': 'hi',
    };
    return langMap[language] ?? 'en';
  }

  void _playAudio(Uint8List audioBytes) async {
    try {
      await _audioPlayer.play(BytesSource(audioBytes));
      print('🔊 Playing audio');
    } catch (e) {
      print('❌ Audio playback error: $e');
    }
  }

  void swapLanguages() {
    setState(() {
      final temp = selectedLang1;
      selectedLang1 = selectedLang2;
      selectedLang2 = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2D3142),
              const Color(0xFF1E1E2E),
              const Color(0xFF2D3142).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildCenterContent(),
              _buildLanguageSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF9B59B6)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Neural Chat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Scribe V2 Realtime',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white54),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCenterContent() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Waveform Animation
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(120, 80),
                  painter: WaveformPainter(
                    animation: _waveController,
                    isActive: isRecording1 || isRecording2,
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            Text(
              'Traduction Instantanée',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Choisissez vos langues et maintenez un\nbouton pour parler naturellement.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Section Langue 1
          Expanded(
            child: _buildLanguageCard(
              language: selectedLang1,
              isLeft: true,
              isRecording: isRecording1,
              transcription: transcription1,
              onLanguageChanged: (lang) => setState(() => selectedLang1 = lang),
              onMicPressed: toggleRecording1,
            ),
          ),
          
          // Bouton Swap
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: swapLanguages,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3142),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: const Icon(
                  Icons.swap_horiz,
                  color: Colors.white54,
                  size: 24,
                ),
              ),
            ),
          ),
          
          // Section Langue 2
          Expanded(
            child: _buildLanguageCard(
              language: selectedLang2,
              isLeft: false,
              isRecording: isRecording2,
              transcription: transcription2,
              onLanguageChanged: (lang) => setState(() => selectedLang2 = lang),
              onMicPressed: toggleRecording2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard({
    required String language,
    required bool isLeft,
    required bool isRecording,
    required String transcription,
    required Function(String) onLanguageChanged,
    required VoidCallback onMicPressed,
  }) {
    final primaryColor = isLeft ? const Color(0xFF3B82F6) : const Color(0xFFEC4899);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF000000).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecording 
              ? primaryColor.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sélecteur de langue
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: language,
              isExpanded: true,
              dropdownColor: const Color(0xFF2D3142),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 20),
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: languages.map((lang) {
                return DropdownMenuItem(
                  value: lang['name'],
                  child: Row(
                    children: [
                      Text(lang['flag']!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(lang['name']!),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => onLanguageChanged(value!),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Zone de transcription
          if (transcription.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E).withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                transcription,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          // Bouton Microphone avec animation améliorée (Press & Hold)
          GestureDetector(
            onLongPressStart: (_) {
              if (!isRecording) onMicPressed(); // Commence l'enregistrement
            },
            onLongPressEnd: (_) {
              if (isRecording) onMicPressed(); // Arrête et lance la traduction
            },
            onTap: () {
              // Simple tap : toggle classique pour compatibilité
              onMicPressed();
            },
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = isRecording ? 1.0 + (_pulseController.value * 0.1) : 1.0;
                
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isRecording
                            ? [const Color(0xFFFF3B30), const Color(0xFFFF6B6B)] // Rouge vif
                            : [primaryColor.withOpacity(0.4), primaryColor.withOpacity(0.3)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: isRecording
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF3B30).withOpacity(0.6 * _pulseController.value),
                                blurRadius: 30,
                                spreadRadius: 8,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                    ),
                    child: Icon(
                      isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: isRecording ? 32 : 28,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Indicateur d'enregistrement
          if (isRecording)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFF3B30).withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: const Text(
                  '🎤 Recording...',
                  style: TextStyle(
                    color: Color(0xFFFF3B30),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 8),
          
          Text(
            language.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isActive;

  WaveformPainter({required this.animation, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive 
          ? const Color(0xFF6C5CE7).withOpacity(0.8)
          : const Color(0xFF6C5CE7).withOpacity(0.3)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final bars = 7;
    final spacing = size.width / (bars * 2);
    
    for (int i = 0; i < bars; i++) {
      final x = spacing + i * spacing * 2;
      final heightFactor = math.sin((animation.value * 2 * math.pi) + (i * 0.5));
      final barHeight = (size.height / 2) * (isActive ? (0.3 + heightFactor.abs() * 0.7) : 0.3);
      
      canvas.drawLine(
        Offset(x, size.height / 2 - barHeight / 2),
        Offset(x, size.height / 2 + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) => true;
}
