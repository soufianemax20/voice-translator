import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import ajouté
import 'dart:io';

import 'services/mobile_audio_recorder.dart';
import 'services/beam_ai_service.dart'; // ✅ Beam AI - Unified H100 GPU

import 'services/security_check.dart';
import 'services/audio_player_service.dart';

import 'services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'widgets/holographic_card.dart';
import 'package:record/record.dart'; // Re-enabled (v4.4.4)
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("⚠️ Warning: .env file not found: $e");
  }
  
  // Initialize core services
  await SecurityCheck.initialize();
  await AdService().initialize();
  
  runApp(const VoiceTranslatorApp());
}

class VoiceTranslatorApp extends StatelessWidget {
  const VoiceTranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Translator',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117), // GitHub dark
        primaryColor: const Color(0xFF58A6FF),
        colorScheme: const ColorScheme.dark(
          secondary: Color(0xFF39D353),
          onSurface: Colors.white,
        ),
        // textTheme: TextStyleTextTheme(ThemeData.dark().textTheme),
        textTheme: ThemeData.dark().textTheme,
      ),
      home: const TranslationScreen(),
    );
  }
}


// GLOBAL STATE for Settings (To ensure Toggle reliability)
bool gEnableVoiceCloning = true;

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  // Services
  MobileAudioRecorder? _recorder1;
  MobileAudioRecorder? _recorder2;
  bool _isFirstSideLast = false; 
  
  // 📥 Download State
  double _downloadProgress = 0.0;
  bool _isDownloadingModels = false;
  StreamSubscription? _downloadSubscription;

  // 🔒 CRITICAL: Global processing lock - blocks ALL interactions
  bool _isProcessing = false;
  bool _isSttInProgress = false; // 🚦 Lock for STT Micro-Batches
  bool _isFinalizing = false; // 🛑 Lock to prevent micro-batches from overwriting final result

  // 🏦 VOICE BANK (v46): Cache good long samples for cloning short ones
  File? _cachedSpeakerRef1;
  File? _cachedSpeakerRef2;
  bool isRecording1 = false;
  bool isRecording2 = false;
  
  String transcription1 = '';
  String transcription2 = '';
  
  // 📝 NATIVE FILE SINK FOR CLONING
  IOSink? _audioFileSink;

  // Credits System
  // Initialize to 0, will be loaded from prefs. 
  // If first time, will be set to 30 in _loadCredits.
  int _credits = 0; 
  // Cost increased to reflect real API costs (ElevenLabs TTS is expensive)
  // 1 Ad (~0.01$) ~= 1 Translation with TTS (~0.03$) - still subsidizing but better.
  final int _costPerTranslation = 30; 
  static const String _prefsCreditsKey = 'user_credits';
  
  // Banner Ad State
  bool _isBannerVisible = false;

  // Languages & Gender
  String selectedLang1 = 'English';
  String selectedLang2 = 'French';
  String gender1 = 'male';   
  String gender2 = 'female';

  // Services
  final AdService _adService = AdService();
  final SecurityCheck _securityCheck = SecurityCheck();
  final BeamAiService _beamService = BeamAiService();
  final AudioPlayerService _audioPlayer = AudioPlayerService();

  // Concurrency control: Track active audio tasks to avoid overlaps
  bool _isAudioPlaying = false;

  // Language Code Map for TTS
  final Map<String, String> _langCodes = {
    'Arabic': 'ar-SA',
    'English': 'en-US',
    'French': 'fr-FR',
    'Spanish': 'es-ES',
    'German': 'de-DE',
    'Italian': 'it-IT',
    'Japanese': 'ja-JP',
    'Chinese': 'zh-CN',
    'Russian': 'ru-RU',
    'Hindi': 'hi-IN',
    // 2-letter code support
    'ar': 'ar-SA', 'en': 'en-US', 'fr': 'fr-FR', 'es': 'es-ES',
    'de': 'de-DE', 'it': 'it-IT', 'ja': 'ja-JP', 'zh': 'zh-CN',
    'ru': 'ru-RU', 'hi': 'hi-IN',
  };

  // Groq TTS Service
  // final GroqTtsService _groqTtsService = GroqTtsService();
  // final QwenService _qwenService = QwenService(); // Qwen Omni instance

  // Using OpenAI Unlimited TTS by default.

  // Audio storage for replay
  // Audio storage for replay (Paths)
  String? _lastAudio1;
  String? _lastAudio2;
  String? _lastRecordingPath1;
  String? _lastRecordingPath2;

  final List<String> languages = [

    'English', 'Japanese', 'Chinese', 'German', 'Hindi', 'French', 'Korean', 'Portuguese', 
    'Italian', 'Spanish', 'Indonesian', 'Dutch', 'Turkish', 'Filipino', 'Polish', 'Swedish', 
    'Bulgarian', 'Romanian', 'Arabic', 'Czech', 'Greek', 'Finnish', 'Croatian', 'Malay', 
    'Slovak', 'Danish', 'Tamil', 'Ukrainian', 'Russian'
  ];

  // Animation Controllers
  // 🚀 STREAMING CORE: Buffer for real-time STT
  final List<int> _liveAudioBuffer = [];
  StreamSubscription? _audioStreamSub;
  Timer? _microBatchTimer;
  bool _isFinalProcessing = false;
  String _alreadyProcessedText = "";

  // 📝 SENTENCE TRACKER (v40/v62): Ensures no phrase is forgotten
  final Set<String> _processedSegmentsSide1 = {};
  final Set<String> _processedSegmentsSide2 = {};

  String _accumulatedTranslationsSide1 = "";
  String _accumulatedTranslationsSide2 = "";

  // 🧪 DIAGNOSTICS (v43): Trace exact backend state
  String _beamStatus1 = "";
  String _beamStatus2 = "";

  late AnimationController _floatController1;
  late AnimationController _floatController2;
  final TextEditingController _configUrlController = TextEditingController();
  
  // 🔊 OUTPUT QUEUE: Buffers audio during recording for delayed playback
  final List<Uint8List> _audioOutputQueue = [];
  
  // 🧬 CLONING DNA: Accumulates audio until we have a perfect 5s sample
  final List<int> _cloningHistoryBuffer = []; 
  File? _stableMasterRefFile;
  bool _voiceMasterLocked = false;

  // Progress Simulation State
  String _generationStatus = "Initializing...";
  Timer? _progressTimer;
  bool _isDevMode = true; // Enabled for testing
  // bool _isCloningEnabled = true; // NEW: Voice Cloning Toggle
  bool _isGenerating = false;
  double _generationProgress = 0.0;

  bool isPlaying = false; 
  bool streamFinished = false;

  // NEW: Fullscreen / Focus Mode State
  bool _isPanel1Fullscreen = false;
  bool _isPanel2Fullscreen = false;

  // NEW: Voice Sample Optimization (Send only once per session)
  bool _voiceSample1Sent = false;
  bool _voiceSample2Sent = false;

  // New Features State
  // F5-TTS: Voice tone is derived automatically from reference audio.
  // Legacy mood settings removed for clarity and stability.


  final List<String> _statusMessages = [
    "Analyzing accent...",
    "Synthesizing vocal folds...",
    "Adjusting pitch...",
    "Rendering audio...",
    "Polishing pronunciation...",
    "Finalizing wave format..."
  ];

  // 🛡️ [v81] ENHANCED SERVER KEEP-ALIVE: Prevents Space from hibernating
  Timer? _keepAliveTimer;
  int _keepAliveTick = 0;
  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
       try {
         _keepAliveTick++;
         if (_keepAliveTick % 10 == 0) {
           // Every 10 mins: DEEP heartbeat (triggers GPU session to keep it resident)
           debugPrint("💓 Server Keep-Alive: Sending Deep Heartbeat...");
           await _beamService.deepHeartbeat();
         } else {
           // Every 1 min: LIGHT heartbeat (keeps container alive)
           await _beamService.health();
           debugPrint("❤️ Server Keep-Alive: Ping Sent");
         }
       } catch (e) {
         debugPrint("⚠️ Keep-Alive Ping Failed: $e");
       }
    });
  }

  // Waveform Animation State
  final ValueNotifier<List<double>> _waveDataNotifier = ValueNotifier(List.filled(40, 0.0));
  Timer? _waveTimer;

  void _startWaveAnimation() {
    _waveTimer?.cancel();
    _waveTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _waveDataNotifier.value = List.generate(40, (index) => math.Random().nextDouble());
    });
  }

  void _stopWaveAnimation() {
    _waveTimer?.cancel();
    _waveDataNotifier.value = List.filled(40, 0.0);
  }

  void _startProgressSimulation(String text) {
    setState(() {
      _isGenerating = true;
      _generationProgress = 0.0;
      _generationStatus = "Contacting Kaggle GPU...";
    });

    double durationInSeconds = (text.length / 5.0).clamp(3.0, 15.0);
    double step = 0.01;
    int intervalMs = (durationInSeconds * 10).toInt();

    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (_generationProgress < 0.92 && mounted) {
        setState(() {
          _generationProgress += step;
          _generationStatus = _statusMessages[((_generationProgress * 100) / 15).floor() % _statusMessages.length];
        });
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _generationStatus = "Almost ready...";
          });
        }
      }
    });
  }

  void _finishProgress() {
    _progressTimer?.cancel();
    if (mounted) {
      setState(() {
        _generationProgress = 1.0;
        _generationStatus = "Success!";
      });
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    });
  }

  // State for Settings
  // bool _enableVoiceCloning = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCredits(); // Load credits on startup
    _loadSettings(); // Load settings for fast mode and URL
    // _localAiService.initSttModel(); // Init Local AI - REMOVED
    // _setupLocalAiListener(); // REMOVED
    _requestPermissions();
    _floatController1 = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true);
    _floatController2 = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat(reverse: true);
    _startKeepAlive();
    
    // Initialize Puter WebView Bridge (100% Puter.com integration)
    // Puter Initialization Removed
    
    // Pre-warm API connections for ultra-fast first request
    _warmUpConnections();
    
    _adService.loadBannerAd(
      onAdLoaded: (ad) => setState(() => _isBannerVisible = true),
      onAdFailed: (ad, error) => setState(() => _isBannerVisible = false),
    );
  }

  // _setupLocalAiListener removed

  // Persistent Credits System
  Future<void> _loadCredits() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Check if key exists. If not, it's a fresh install.
      // STRATEGY CHANGE: Start with 0 to prevent "Clear Data" exploit.
      // Users must watch an ad for their first translation.
      if (!prefs.containsKey(_prefsCreditsKey)) {
        _credits = 0; 
        prefs.setInt(_prefsCreditsKey, 0);
      } else {
        _credits = prefs.getInt(_prefsCreditsKey) ?? 0;
      }
    });
  }

  Future<void> _saveCredits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsCreditsKey, _credits);
  }

  Future<void> _loadSettings() async {
     final prefs = await SharedPreferences.getInstance();
     setState(() {
        _isDevMode = prefs.getBool('is_dev_mode') ?? false; // PERSISTENCE FIX
        gEnableVoiceCloning = prefs.getBool('is_cloning_enabled') ?? true; // NEW Persistence

        final savedUrl = prefs.getString('chatterbox_url') ?? "https://lowbred-blotchier-eleanore.ngrok-free.dev";
        _configUrlController.text = savedUrl;
        // UnlimitedTtsService.updateHost(savedUrl);
     });
  }

  Future<void> _saveSettings() async {
     final prefs = await SharedPreferences.getInstance();
     await prefs.setBool('is_dev_mode', _isDevMode); // PERSISTENCE FIX
     await prefs.setBool('is_cloning_enabled', gEnableVoiceCloning); // NEW Persistence

     await prefs.setString('chatterbox_url', _configUrlController.text.trim());
     // UnlimitedTtsService.updateHost(_configUrlController.text.trim());
  }

  // Removed: XTTS and Unlimited settings no longer needed separately.

  // Removed: XTTS persistence no longer needed.

  Future<void> _warmUpConnections() async {
    // 🧛 VAMPIRE WARMUP: Wake up the Beam GPU instantly
    await _beamService.preWarmup();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _floatController1.dispose();
    _keepAliveTimer?.cancel();
    _floatController2.dispose();
    _recorder1?.dispose();
    _recorder2?.dispose();
    // Clean Dispose
    _audioPlayer.dispose();
    _adService.disposeBannerAd();
    _configUrlController.dispose();
    _downloadSubscription?.cancel();
    _microBatchTimer?.cancel();
    _audioStreamSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _adService.showAppOpenAdIfAvailable();
      _loadCredits(); // Refresh credits when resuming to be safe
    }
  }
  
  void _showRewardedAd() {
    bool isShown = _adService.showRewardedAd(onUserEarnedReward: (reward) {
      setState(() => _credits += 30); // Reward = 1 Translation
      _saveCredits(); // Save immediately after earning
      _showStyledSnackBar("+ 30 credits earned (1 Translation)");
    });

    if (!isShown) {
      _showStyledSnackBar("Ad is loading... Please wait a moment.", isError: true);
    }
  }

  void _showInsufficientCreditsDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDA3633), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFDA3633), size: 24),
                  const SizedBox(width: 12),
                  Text(
                    "Insufficient Credits",
                    style: TextStyle(
                      color: const Color(0xFFDA3633),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Translation requires $_costPerTranslation credits.\nBalance: $_credits credits\n\nEarn more by watching an ad.",
                style: TextStyle(color: const Color(0xFF8B949E), fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: TextStyle(color: const Color(0xFF8B949E))),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showRewardedAd();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF238636),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(
                      "Watch Ad (+30)",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getLangCode(String lang) {
    switch (lang) {
      case 'English': return 'en';
      case 'Japanese': return 'ja';
      case 'Chinese': return 'zh';
      case 'German': return 'de';
      case 'Hindi': return 'hi';
      case 'French': return 'fr';
      case 'Korean': return 'ko';
      case 'Portuguese': return 'pt';
      case 'Italian': return 'it';
      case 'Spanish': return 'es';
      case 'Indonesian': return 'id';
      case 'Dutch': return 'nl';
      case 'Turkish': return 'tr';
      case 'Filipino': return 'fil';
      case 'Polish': return 'pl';
      case 'Swedish': return 'sv';
      case 'Bulgarian': return 'bg';
      case 'Romanian': return 'ro';
      case 'Arabic': return 'ar';
      case 'Czech': return 'cs';
      case 'Greek': return 'el';
      case 'Finnish': return 'fi';
      case 'Croatian': return 'hr';
      case 'Malay': return 'ms';
      case 'Slovak': return 'sk';
      case 'Danish': return 'da';
      case 'Tamil': return 'ta';
      case 'Ukrainian': return 'uk';
      case 'Russian': return 'ru';
      default: return 'en';
    }
  }

  Future<void> _requestPermissions() async {
    await [Permission.microphone, Permission.storage].request();
  }

  // Dynamic Cost System
  Timer? _recordingTimer;
  int _currentDurationSec = 0;
  int _currentCost = 30; // Starts at base cost

  void _startDurationCheck(bool isSide1) {
    _recordingTimer?.cancel();
    _currentDurationSec = 0;
    _currentCost = 30;
    
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentDurationSec++;
        
        // Calculate cost based on duration tiers
        if (_currentDurationSec <= 15) {
          _currentCost = 30;
        } else if (_currentDurationSec <= 30) {
          _currentCost = 60;
        } else {
          _currentCost = 90 + ((_currentDurationSec - 30) * 2); // +2 credits per extra sec
        }
      });

      // CHECK: Do we have enough credits for the NEXT second?
      // If we are at 15s (cost 30) and going to 16s (cost 60), but user has only 50... STOP.
      int nextSecondCost = _currentCost;
      if (_currentDurationSec == 15) nextSecondCost = 60;
      if (_currentDurationSec == 30) nextSecondCost = 90;

      if (_credits < nextSecondCost && !_isDevMode) {
        // Auto-stop recording because user can't afford next tier
        if (isSide1) {
          _stopRecording1();
        } else {
          _stopRecording2();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Limit reached! Watch ads to record longer.", style: TextStyle()),
            backgroundColor: const Color(0xFFDA3633),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _startRecording1() async {
    if (_isProcessing) return;
    try {
      if (await Permission.microphone.request().isGranted) {
        setState(() {
          isRecording1 = true;
          transcription1 = "🎧 Instant Listening...";
          transcription2 = "";
          _liveAudioBuffer.clear();
          _cloningHistoryBuffer.clear();
          _processedSegmentsSide1.clear();
          _accumulatedTranslationsSide1 = "";
          _isSttInProgress = false;
          _isFinalProcessing = false;
          _alreadyProcessedText = "";
          _beamStatus1 = "READY";
          _floatController1.repeat(reverse: true);
        });
        
        // 🧛 PROACTIVE WARMUP: Wake up the Beam GPU as soon as user touches the button
        _beamService.preWarmup();
        
        _startWaveAnimation();
        _recorder1 = MobileAudioRecorder();
        _audioOutputQueue.clear();
        

        
        // 📝 CREATE CLONING FILE SINK
        final dir = await getTemporaryDirectory();
        final clonePath = '${dir.path}/cloning_ref_side1.wav';
        _audioFileSink = File(clonePath).openWrite();
        
        // VAD State
        DateTime? silenceStart;
        const int silenceThreshold = 500; // Amplitude threshold (adjust as needed)
        const int silenceDurationMs = 1500; // 1.5 seconds of silence to trigger
        
        final stream = await _recorder1?.startStreaming();
        if (stream != null) {
          _audioStreamSub = stream.listen((chunk) {
             _liveAudioBuffer.addAll(chunk);
             // 📝 DUAL RECORDING: Save to file for perfect cloning
             _audioFileSink?.add(chunk);
             
             // VAD removed as requested to prevent premature cutouts
          });

          // ⚡ INSTANT MICRO-BATCH (v41): Trigger every 2s for "phrase-by-phrase" feedback
          _microBatchTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
             _processLiveMicroBatch(true);
          });
        }
        
        _startDurationCheck(true);
      }
    } catch (e) {
      print("❌ Start Recording Error: $e");
    }
  }

  void _stopRecording1() async {
    // Prevent double calling
    if (!isRecording1) return;
    
    try {
      // 🚀 V64: IMMEDIATE HARDWARE STOP
      _microBatchTimer?.cancel();
      _microBatchTimer = null;
      
      await _audioStreamSub?.cancel();
      _audioStreamSub = null; 
      
      _recordingTimer?.cancel();
      _recordingTimer = null;

      // 🛑 STOP RECORDER INSTANTLY
      await _recorder1?.stopRecording();

      // 📱 IMMEDIATE UI FEEDBACK
      setState(() => isRecording1 = false);
      _stopWaveAnimation(); 

      // 🔊 INSTANT PLAYBACK (v65): Start playing already synthesized segments now
      _playAudioOutputQueue();

      // 🧠 BACKGROUND FINALIZATION (V64)
      _isFinalProcessing = true;
      _processFinalS2ST(true).then((_) {
        _isFinalProcessing = false;
        _playAudioOutputQueue();
      });
    } catch (e) {
       print("❌ Error in _stopRecording1: $e");
    } finally {
       if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _processSentenceTTS(String text, String lang, bool isMale, bool isSide1) async {
    try {
       // 🎤 VOICE CLONING: Atomic Snapshot Strategy (Fixes 422 File Lock)
       File? refFile;
       
       // Only try to clone if we have decent audio (>15s is ideal, but >2s min)
       // We use _liveAudioBuffer which is safe in memory.
       if (gEnableVoiceCloning && _liveAudioBuffer.length > 32000) {
           try {
               final dir = await getTemporaryDirectory();
               // Use only the last ~7 seconds of audio for the reference snapshot
               // 16000 samples/sec * 2 bytes/sample * 7 seconds = 224,000 bytes
               const int maxSnapshotSize = 16000 * 2 * 7;
               final List<int> snapshotBuffer = _liveAudioBuffer.length > maxSnapshotSize 
                   ? _liveAudioBuffer.sublist(_liveAudioBuffer.length - maxSnapshotSize)
                   : List<int>.from(_liveAudioBuffer);

               // Create a clean WAV file from this optimized buffer segment
               final String snapshotName = "voice_optimized_${DateTime.now().millisecondsSinceEpoch}.wav";
               final String snapshotPath = "${(await getTemporaryDirectory()).path}/$snapshotName";
               final File snapshotFile = File(snapshotPath);
               
               final bytes = WaveHeader.addWavHeader(snapshotBuffer, 16000, 1, 16);
               await snapshotFile.writeAsBytes(bytes, flush: true);
               
               if (await snapshotFile.length() > 1000) { // Safety check
                  refFile = snapshotFile;
               }
           } catch (e) {
               print("⚠️ Snapshot Write Failed: $e");
           }
       }

        if (isSide1) _beamStatus1 = "SYNTHESIZING..."; else _beamStatus2 = "SYNTHESIZING...";
        setState(() {});

        // 🔙 ROLLBACK (v73): Revert to stable "whole file" synthesis
        // The streaming pipeline (v66) was causing playback failures on some devices.
        debugPrint("🔊 [v73] Synthesizing full audio for: '$text'...");
        
        final audioBytes = await _beamService.synthesize(
            text,
            lang,
            inputAudio: refFile,
        );

        // Final cleanup of temp audio snapshot (Mic reference)
        if (refFile != null && await refFile.exists()) {
           try {
              await refFile.delete();
              print("🧹 Temporary voice snapshot deleted.");
           } catch (e) {
              print("⚠️ Cleanup failed: $e");
           }
        }

        if (audioBytes != null && audioBytes.isNotEmpty) {
          debugPrint("✅ [v75] Audio ready (${audioBytes.length} bytes). Waiting for recording to finish...");
          
          // 🛡️ User Request: Don't start pronouncing until the record button is released
          while (isRecording1 || isRecording2) {
             await Future.delayed(const Duration(milliseconds: 100));
          }

          debugPrint("🔊 [v75] Playing synthesized sentence...");
          // 🔊 Use the robust playFromBytes which writes to a temp file first
          await _audioPlayer.playFromBytes(audioBytes);
        } else {
           print("❌ TTS Synthesis failed for: '$text'");
        }
    } catch (e) {
       print("TTS Pipeline Error: $e");
    }
  }

  // Sequential playback Consumer
  bool _isPlayingQueue = false;

  void _processAudioQueue() async {
    if (_isPlayingQueue || _audioOutputQueue.isEmpty || isRecording1 || isRecording2) return;
    
    _isPlayingQueue = true;
    try {
      while (_audioOutputQueue.isNotEmpty) {
        final bytes = _audioOutputQueue.removeAt(0);
        
        // 🔊 playFromBytes ALREADY waits for completion in AudioPlayerService
        await _audioPlayer.playFromBytes(bytes);
      }
    } catch (e) {
      print("Audio Queue Error: $e");
    } finally {
      _isPlayingQueue = false;
      if (_audioOutputQueue.isNotEmpty) _processAudioQueue();
    }
  }

  // Deprecated direct name, mapping to new robust consumer
  void _playAudioOutputQueue() => _processAudioQueue();

  // 🚀 UNIFIED FINAL PROCESSING (v44)
  Future<void> _processFinalS2ST(bool isSide1) async {
    if (_liveAudioBuffer.isEmpty) return;
    
    // 🛑 LOCK: Prevent any late micro-batches from updating UI
    _isFinalizing = true;

    try {
      final String sourceCode = _getLangCode(isSide1 ? selectedLang1 : selectedLang2).split('-')[0];
      final String targetCode = _getLangCode(isSide1 ? selectedLang2 : selectedLang1).split('-')[0];
      
      if (isSide1) _beamStatus1 = "FINALIZING..."; else _beamStatus2 = "FINALIZING...";
      setState(() {});

      final dir = await getTemporaryDirectory();
      final tempFile = File('${dir.path}/final_s2st.wav');
      final wavBytes = WaveHeader.addWavHeader(_liveAudioBuffer, 16000, 1, 16);
      await tempFile.writeAsBytes(wavBytes);

      // Create a snapshot for voice cloning
      File? refFile;
      
      // 🏦 VOICE BANK LOGIC:
      // 1. If current audio is LONG (> 2s approx ~32k bytes @ 16khz mono), USE IT and CACHE IT.
      // 2. If current audio is SHORT, try to use CACHED ref.
      
      if (gEnableVoiceCloning) {
        if (_liveAudioBuffer.length > 32000) {
          // ✅ LONG ENOUGH: Create new ref and update cache
          final snapshotPath = "${dir.path}/final_ref_${isSide1 ? '1' : '2'}_${DateTime.now().millisecondsSinceEpoch}.wav";
          final snapshotFile = File(snapshotPath);
          await snapshotFile.writeAsBytes(wavBytes); 
          refFile = snapshotFile;
          
          // Update Cache
          if (isSide1) {
            _cachedSpeakerRef1 = snapshotFile;
             print("🏦 Voice Bank (Side 1) Updated with new sample (${_liveAudioBuffer.length} bytes)");
          } else {
            _cachedSpeakerRef2 = snapshotFile;
             print("🏦 Voice Bank (Side 2) Updated with new sample (${_liveAudioBuffer.length} bytes)");
          }

        } else {
          // ⚠️ TOO SHORT: Attempt Cache Fallback
          print("⚠️ Audio too short for fresh clone (${_liveAudioBuffer.length} bytes). Checking Voice Bank...");
          if (isSide1 && _cachedSpeakerRef1 != null) {
            refFile = _cachedSpeakerRef1;
            print("✅ Using Cached Voice Bank (Side 1)");
          } else if (!isSide1 && _cachedSpeakerRef2 != null) {
            refFile = _cachedSpeakerRef2;
            print("✅ Using Cached Voice Bank (Side 2)");
          } else {
            print("❌ No cached voice available. Fallback to System Default.");
          }
        }
      }

      final result = await _beamService.s2st(
        tempFile,
        targetCode,
        sourceLang: sourceCode,
        speakerRef: refFile
      );

      if (result != null && result['error'] == null) {
        final String fullText = result['text'] ?? "";
        final String fullTranslated = result['translated'] ?? "";
        
        // 🎯 Update UI with Full Results immediately
        setState(() {
          if (isSide1) {
            transcription1 = fullText;
            transcription2 = fullTranslated;
          } else {
            transcription2 = fullText;
            transcription1 = fullTranslated;
          }
        });

        // 🕵️ IDENTIFY TAIL: What wasn't processed during the live recording?
        final Set<String> processedSet = isSide1 ? _processedSegmentsSide1 : _processedSegmentsSide2;
        final Set<String> normalizedProcessed = processedSet.map((s) => _normalizeForComparison(s)).toSet();
        
        final RegExp sentenceSplitter = RegExp(r'(?<=[.!?])\s+');
        final List<String> finalSentences = fullText.split(sentenceSplitter);
        
        String tailText = "";
        for (String sentence in finalSentences) {
          String trimmed = sentence.trim();
          if (trimmed.isEmpty || trimmed.length < 5) continue;
          
          String normalized = _normalizeForComparison(trimmed);
          if (!normalizedProcessed.contains(normalized)) {
            print("✨ Dual-Trigger (Tail): Found unprocessed sentence: '$trimmed'");
            tailText = (tailText.isEmpty ? "" : "$tailText ") + trimmed;
            processedSet.add(trimmed); // Mark as processed
          }
        }

        if (tailText.isNotEmpty) {
          print("📝 S2ST Final: Processing Tail Text: '$tailText'");
          final String targetCode = _getLangCode(isSide1 ? selectedLang2 : selectedLang1).split('-')[0];
          
          // ✂️ SEQUENTIAL TAIL (v65): Split into sentences for faster feedback
          final List<String> tailSentences = tailText.split(sentenceSplitter);
          for (String tailSentence in tailSentences) {
            String trimmedTail = tailSentence.trim();
            if (trimmedTail.isEmpty) continue;
            
            final tailTranslation = await _beamService.translate(trimmedTail, targetCode, sourceLang: sourceCode);
            if (tailTranslation != null && tailTranslation.isNotEmpty) {
               _updateAccumulatedTranslation(tailTranslation, isSide1);
               // 🚀 ASYNC STREAMING: Don't block the loop, let the player queue them
               _processSentenceTTS(
                  tailTranslation, 
                  targetCode, 
                  isSide1 ? (gender1 == 'male') : (gender2 == 'male'), 
                  isSide1
                );
            }
          }
        }
      }

      // Cleanup
      if (refFile != null && await refFile.exists()) await refFile.delete();
      if (await tempFile.exists()) await tempFile.delete();

    } catch (e) {
      print("❌ Final S2ST Error: $e");
    } finally {
      if (isSide1) _beamStatus1 = ""; else _beamStatus2 = "";
      _isFinalizing = false; // 🔓 Release lock
      setState(() {});
    }
  }

  Future<void> _processLiveMicroBatch(bool isSide1) async {
    // 🛑 Late Check: If finalization started, ABORT immediately
    if (_liveAudioBuffer.isEmpty || _isSttInProgress || _isFinalizing) return;
    
    _isSttInProgress = true;
    try {
      final String sourceIso = _getLangCode(isSide1 ? selectedLang1 : selectedLang2);
      final dir = await getTemporaryDirectory();
      final tempFile = File('${dir.path}/temp_stt.wav');
      final wavBytes = WaveHeader.addWavHeader(_liveAudioBuffer, 16000, 1, 16);
      await tempFile.writeAsBytes(wavBytes);

      if (isSide1) _beamStatus1 = "TRANSCRIBING..."; else _beamStatus2 = "TRANSCRIBING...";
      setState(() {});

      final sttText = await _beamService.transcribe(
        tempFile,
        lang: sourceIso.split('-')[0], 
      );

      if (sttText == null || sttText.trim().isEmpty) return;
      String cleanStt = sttText.trim();

      // 📺 INSTANT UI UPDATE: Show what user is saying in real-time
      // ⚠️ CRITICAL: Clear the translation field while recording to avoid confusion
      // The user wants to see *only* raw transcription during speech.
      if (!_isFinalizing) { // Double check before set state
        setState(() {
          if (isSide1) {
            transcription1 = cleanStt;
            transcription2 = "..."; // Placeholder until release
          } else {
            transcription2 = cleanStt;
            transcription1 = "..."; // Placeholder until release
          }
        });
      }

      // 📺 INSTANT UI UPDATE: Show what user is saying in real-time
      if (!_isFinalizing) {
        setState(() {
          if (isSide1) {
            transcription1 = cleanStt;
          } else {
            transcription2 = cleanStt;
          }
        });
      }

      // 🧠 DUAL-TRIGGER SEGMENTATION (v62):
      // Trigger 1: Sentence Punctuation (.!?)
      // Trigger 2: 2s Silence Fail-safe
      
      final RegExp sentenceSplitter = RegExp(r'(?<=[.!?])\s+');
      final List<String> currentSegments = cleanStt.split(sentenceSplitter);
      final Set<String> processedSet = isSide1 ? _processedSegmentsSide1 : _processedSegmentsSide2;
      final String sourceCode = sourceIso.split('-')[0];
      final String targetCode = _getLangCode(isSide1 ? selectedLang2 : selectedLang1).split('-')[0];

      // --- TRIGGER 1: SENTENCE-BASED ---
      for (String segment in currentSegments) {
        String trimmedSegment = segment.trim();
        if (trimmedSegment.isEmpty || trimmedSegment.length < 5) continue;

        // If it ends in punctuation, it's a stable sentence
        bool hasPunctuation = RegExp(r'[.!?]$').hasMatch(trimmedSegment);
        
        if (hasPunctuation && !processedSet.contains(trimmedSegment)) {
          processedSet.add(trimmedSegment);
          print("🎯 Dual-Trigger (Sentence): Processing '$trimmedSegment'");
          
          final translation = await _beamService.translate(trimmedSegment, targetCode, sourceLang: sourceCode);
          if (translation != null && !_isFinalizing) {
            _updateAccumulatedTranslation(translation, isSide1);
            // 🚀 ASYNC STREAMING (v66): Fire-and-forget, player handles sequential locking
            _processSentenceTTS(translation, targetCode, isSide1 ? (gender1 == 'male') : (gender2 == 'male'), isSide1);
          }
        }
      }

      // --- TRIGGER 2: SILENCE-BASED FAIL-SAFE ---
      const int silenceWindow = 32000; // 2s @ 16kHz
      if (_liveAudioBuffer.length >= silenceWindow) {
        final lastWindow = _liveAudioBuffer.sublist(_liveAudioBuffer.length - silenceWindow);
        double sum = 0;
        for (var sample in lastWindow) sum += sample.abs();
        double avgEnergy = sum / silenceWindow;

        // If silent and there's unprocessed text (even without punctuation)
        if (avgEnergy < 350) {
           // We find what text remains unprocessed
           String remainingText = cleanStt;
           for (var p in processedSet) {
             remainingText = remainingText.replaceFirst(p, "");
           }
           remainingText = remainingText.trim();

           if (remainingText.length > 5) {
             print("🤫 Dual-Trigger (Silence): Processing '$remainingText'");
             processedSet.add(remainingText); // Mark as processed to avoid loops
             
             final translation = await _beamService.translate(remainingText, targetCode, sourceLang: sourceCode);
             if (translation != null && !_isFinalizing) {
               _updateAccumulatedTranslation(translation, isSide1);
               // 🚀 ASYNC STREAMING (v66)
               _processSentenceTTS(translation, targetCode, isSide1 ? (gender1 == 'male') : (gender2 == 'male'), isSide1);
             }
           }
        }
      }

      // ✂️ BUFFER MANAGEMENT: (V63) STOPPED aggressive trimming to preserve full context for final pass
      // if (_liveAudioBuffer.length > 48000) {
      //    _liveAudioBuffer.removeRange(0, _liveAudioBuffer.length - 16000); 
      // }

      print("📝 Live Transcription: $cleanStt");

    } catch (e) {
      print("Error in micro-batch: $e");
    } finally {
      _isSttInProgress = false;
      if (isSide1) _beamStatus1 = ""; else _beamStatus2 = "";
      if (mounted && (isSide1 ? isRecording1 : isRecording2)) setState(() {});
    }
  }

  void _updateAccumulatedTranslation(String translation, bool isSide1) {
    setState(() {
      if (isSide1) {
        _accumulatedTranslationsSide1 = (_accumulatedTranslationsSide1.isEmpty ? "" : "$_accumulatedTranslationsSide1 ") + translation;
        transcription2 = _accumulatedTranslationsSide1;
        transcription1 = ""; // Clear live text for next paragraph
      } else {
        _accumulatedTranslationsSide2 = (_accumulatedTranslationsSide2.isEmpty ? "" : "$_accumulatedTranslationsSide2 ") + translation;
        transcription1 = _accumulatedTranslationsSide2;
        transcription2 = ""; // Clear live text for next paragraph
      }
    });
  }

  String _normalizeForComparison(String text) {
     return text.toLowerCase().replaceAll(RegExp(r'[.!?,\s]'), "");
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'fr': return "French";
      case 'en': return "English";
      case 'es': return "Spanish";
      case 'ar': return "Arabic";
      case 'de': return "German";
      case 'it': return "Italian";
      case 'pt': return "Portuguese";
      case 'ru': return "Russian";
      case 'zh': return "Chinese";
      case 'ja': return "Japanese";
      case 'ko': return "Korean";
      case 'hi': return "Hindi";
      default: return "English";
    }
  }


  void _startRecording2() async {
    if (_isProcessing) return;
    try {
      if (await Permission.microphone.request().isGranted) {
        setState(() {
          isRecording2 = true;
          transcription2 = "🎧 Instant Listening...";
          transcription1 = "";
          _liveAudioBuffer.clear();
          _cloningHistoryBuffer.clear();
          _processedSegmentsSide2.clear();
          _accumulatedTranslationsSide2 = "";
          _isSttInProgress = false;
          _isFinalProcessing = false;
          _alreadyProcessedText = "";
          _beamStatus2 = "READY";
          _floatController2.repeat(reverse: true);
        });
        
        // 🧛 PROACTIVE WARMUP: Wake up the Beam GPU as soon as user touches the button
        _beamService.preWarmup();
        
        _startWaveAnimation();
        _recorder2 = MobileAudioRecorder();
        _audioOutputQueue.clear();
        


        // 📝 CREATE CLONING FILE SINK SIDE 2
        final dir = await getTemporaryDirectory();
        final clonePath = '${dir.path}/cloning_ref_side2.wav';
        _audioFileSink = File(clonePath).openWrite();

        final stream = await _recorder2?.startStreaming();
        if (stream != null) {
          _audioStreamSub = stream.listen((chunk) {
             _liveAudioBuffer.addAll(chunk);
             _audioFileSink?.add(chunk);
          });

          // ⚡ INSTANT MICRO-BATCH (v41): Trigger every 2s for "phrase-by-phrase" feedback
          _microBatchTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
             _processLiveMicroBatch(false);
          });
        }
        
        _startDurationCheck(false);
      }
    } catch (e) {
      print("❌ Start Recording Error: $e");
    }
  }

  void _stopRecording2() async {
    try {
      // 🚀 V64: IMMEDIATE HARDWARE STOP
      _microBatchTimer?.cancel();
      _microBatchTimer = null;
      
      await _audioStreamSub?.cancel();
      _audioStreamSub = null; 
      
      _recordingTimer?.cancel();
      _recordingTimer = null;

      // 🛑 STOP RECORDER INSTANTLY
      await _recorder2?.stopRecording();

      // 📱 IMMEDIATE UI FEEDBACK
      setState(() => isRecording2 = false);
      _stopWaveAnimation(); 

      // 🔊 INSTANT PLAYBACK (v65): Start playing already synthesized segments now
      _playAudioOutputQueue();

      // 🧠 BACKGROUND FINALIZATION (V64)
      _isFinalProcessing = true;
      _processFinalS2ST(false).then((_) {
        _isFinalProcessing = false;
        _playAudioOutputQueue();
      });
    } catch (e) {
       print("❌ Error in _stopRecording2: $e");
    } finally {
       if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _replayAudio(bool isFirstSide) async {
    // Replay text using the unified _speak method
    final text = isFirstSide ? transcription1 : transcription2;
    final lang = isFirstSide ? selectedLang1 : selectedLang2;
    
    final cachedAudio = isFirstSide ? _lastAudio1 : _lastAudio2;
    
    if (text.isNotEmpty) {
      if (cachedAudio != null && File(cachedAudio).existsSync()) {
        print("🔊 Playing cached audio: $cachedAudio");
        await _playAudio(cachedAudio);
      }
    }
  }

  Future<void> _playAudio(String pathOrUrl, {bool isUrl = false}) async {
    try {
      // Force timeout after 45 seconds max to avoid infinite blocking
      await _audioPlayer.playFromFile(pathOrUrl).timeout(
        const Duration(seconds: 45),
        onTimeout: () {
            print("⚠️ Audio Playback Timeout - Force Unblocking");
            return;
        }
      );
    } catch (e) {
      print("❌ Audio Playback Error: $e");
    }
  }

  void _showStyledSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Avoid stacking
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22), // Fond terminal
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isError ? const Color(0xFFDA3633) : const Color(0xFF238636), // Rouge ou Vert
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? const Color(0xFFDA3633) : const Color(0xFF238636),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: const Color(0xFFC9D1D9), // Texte clair
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1117),
      isScrollControlled: true,
      builder: (context) => Container(
        height: 550,
        decoration: const BoxDecoration(
          color: Color(0xFF0D1117),
          border: Border(top: BorderSide(color: Color(0xFF30363D), width: 1)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(
              "// Select Languages",
              style: TextStyle(
                color: const Color(0xFF8B949E),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildLanguageList(true)),
                  Container(width: 1, color: const Color(0xFF21262D)),
                  Expanded(child: _buildLanguageList(false)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageList(bool isLeft) {
    return ListView.builder(
      itemCount: languages.length,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemBuilder: (context, index) {
        final lang = languages[index];
        final isSelected = isLeft ? (selectedLang1 == lang) : (selectedLang2 == lang);
        final accentColor = isLeft ? const Color(0xFF58A6FF) : const Color(0xFF39D353);
        
        return InkWell(
          onTap: () {
            setState(() {
              if (isLeft) {
                if (selectedLang2 == lang) selectedLang2 = selectedLang1;
                selectedLang1 = lang;
              } else {
                if (selectedLang1 == lang) selectedLang1 = selectedLang2;
                selectedLang2 = lang;
              }
            });
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? accentColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: isSelected 
                  ? Border.all(color: accentColor.withOpacity(0.5), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                if (isSelected)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Text(
                    lang,
                    style: TextStyle(
                      color: isSelected ? accentColor : const Color(0xFF8B949E),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildTerminalHeader(),
            
            Expanded(
              child: Column(
                children: [
                  // Output panels
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (!_isPanel2Fullscreen)
                            Expanded(
                              flex: _isPanel1Fullscreen ? 1 : 1,
                                child: _buildTerminalPanel(
                                  title: selectedLang1,
                                  content: transcription1,
                                  beamUIStatus: _beamStatus1,
                                  isRecording: isRecording1,
                                  gender: gender1,
                                  onGenderToggle: () => setState(() => gender1 = gender1 == 'male' ? 'female' : 'male'),
                                  isFullscreen: _isPanel1Fullscreen,
                                  onFullscreenToggle: () => setState(() => _isPanel1Fullscreen = !_isPanel1Fullscreen),
                                  color: const Color(0xFF58A6FF),
                                  isFirstSide: true,
                                  transcription1: transcription1,
                                  transcription2: transcription2,
                                  isAudioPlaying: _audioPlayer.isPlaying,
                                ),
                            ),
                          if (!_isPanel1Fullscreen && !_isPanel2Fullscreen)
                            const SizedBox(height: 16),
                          if (!_isPanel1Fullscreen)
                            Expanded(
                              flex: _isPanel2Fullscreen ? 1 : 1,
                                child: _buildTerminalPanel(
                                  title: selectedLang2,
                                  content: transcription2,
                                  beamUIStatus: _beamStatus2,
                                  isRecording: isRecording2,
                                  gender: gender2,
                                  onGenderToggle: () => setState(() => gender2 = gender2 == 'male' ? 'female' : 'male'),
                                  isFullscreen: _isPanel2Fullscreen,
                                  onFullscreenToggle: () => setState(() => _isPanel2Fullscreen = !_isPanel2Fullscreen),
                                  color: const Color(0xFF39D353),
                                  isFirstSide: false,
                                  transcription1: transcription1,
                                  transcription2: transcription2,
                                  isAudioPlaying: _audioPlayer.isPlaying,
                                ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Control buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildControlButton(
                            label: selectedLang1,
                            isRecording: isRecording1,
                            onStart: _startRecording1,
                            onStop: _stopRecording1,
                            color: const Color(0xFF58A6FF),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildControlButton(
                            label: selectedLang2,
                            isRecording: isRecording2,
                            onStart: _startRecording2,
                            onStop: _stopRecording2,
                            color: const Color(0xFF39D353),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Settings button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: _showLanguageSelector,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF21262D),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF30363D), width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.settings, color: Color(0xFF8B949E), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "Configure Languages",
                              style: TextStyle(
                                color: const Color(0xFF8B949E),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
            if (_isBannerVisible)
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFF21262D), width: 1)),
                ),
                child: _adService.getBannerAdWidget(),
              ),
          ],
        ),
      ),
      if (_isGenerating) _buildLoadingOverlay(),
      ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF30363D), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF58A6FF).withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF58A6FF)),
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "${(_generationProgress * 100).toInt()}%",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _generationStatus.toUpperCase(),
                style: TextStyle(
                  color: const Color(0xFF8B949E),
                  fontSize: 10,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _generationProgress,
                  backgroundColor: const Color(0xFF0D1117),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF58A6FF)),
                  minHeight: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "GENERATING NEURAL AUDIO STREAM...",
                style: TextStyle(
                  color: const Color(0xFF58A6FF).withOpacity(0.5),
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showSettingsDialog() {
    // EMERGENCY UNLOCK: If UI is stuck in processing, this button frees it.
    if (_isProcessing) {
      if (mounted) setState(() => _isProcessing = false);
    }
    
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: const Color(0xFF161B22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF30363D), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune, color: Color(0xFF58A6FF), size: 24),
                    const SizedBox(width: 12),
                    Text(
                      "Configuration IA",
                      style: TextStyle(
                        color: const Color(0xFF58A6FF),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Voice Cloning Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Activer le clonage vocal", style: TextStyle(color: Colors.white, fontSize: 13)),
                      Text("Synthèse via votre voix réelle", style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                  Switch(
                    value: gEnableVoiceCloning,
                    activeColor: Colors.deepPurple,
                    onChanged: (val) {
                      setState(() => gEnableVoiceCloning = val);
                    },
                  ),
                ],
              ),
                const SizedBox(height: 16),
              // Developer Mode Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Developer Mode (Unlimited)", style: TextStyle(color: Colors.white, fontSize: 13)),
                  Switch(
                    value: _isDevMode,
                    activeColor: const Color(0xFF58A6FF),
                    onChanged: (val) {
                      setState(() => _isDevMode = val);
                      _saveSettings();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
                
                // Unified Chatterbox TTS Engine is always active.
                // Unified Engine
              Text(
                'ENGINE: GROQ ORPHEUS AI (CLOUD)',
                style: TextStyle(
                  color: const Color(0xFF39D353), // Green
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(color: const Color(0xFF238636).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                     child: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         const Icon(Icons.cloud_done, color: Color(0xFF238636), size: 16),
                         const SizedBox(width: 8),
                         Text("Cloud AI Connected", style: TextStyle(color: Colors.white, fontSize: 12)),
                       ],
                     ),
                   ),
              ),
              const SizedBox(height: 8),
              
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Fermer", style: TextStyle(color: const Color(0xFF8B949E))),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTerminalHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(bottom: BorderSide(color: Color(0xFF21262D), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // ASCII-style logo
              GestureDetector(
                onLongPress: () {
                  setState(() => _credits += 9999);
                  _saveCredits();
                  _showStyledSnackBar("💎 CHEAT ACTIVATED: +9999 CREDITS", isError: false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF30363D), width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "[>_<]",
                    style: TextStyle(
                      color: const Color(0xFF58A6FF),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Logo text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                      children: const [
                        TextSpan(
                          text: 'VOX',
                          style: TextStyle(color: Color(0xFF58A6FF)),
                        ),
                        TextSpan(
                          text: '2',
                          style: TextStyle(color: Color(0xFF39D353)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "REAL TIME TRANSLATOR",
                    style: TextStyle(
                      color: const Color(0xFF484F58),
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            iconSize: 20,
            icon: const Icon(Icons.tune, color: Color(0xFF58A6FF)),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalPanel({
    required String title,
    required String content,
    String? beamUIStatus,
    required bool isRecording,
    required String gender,
    required VoidCallback onGenderToggle,
    required bool isFullscreen,
    required VoidCallback onFullscreenToggle,
    required Color color,
    required bool isFirstSide,
    required String transcription1,
    required String transcription2,
    required bool isAudioPlaying,
  }) {
    final status = beamUIStatus; // Map renamed parameter back for internal use
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isRecording ? color : const Color(0xFF30363D),
          width: isRecording ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                  border: const Border(bottom: BorderSide(color: Color(0xFF21262D), width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isRecording ? const Color(0xFFDA3633) : color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isRecording && _audioOutputQueue.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.amber.withOpacity(0.5), width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.playlist_play, color: Colors.amber, size: 10),
                                const SizedBox(width: 4),
                                Text(
                                  "${_audioOutputQueue.length} segments ready",
                                  style: const TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    GestureDetector(
                      onTap: onGenderToggle,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: color.withOpacity(0.3), width: 1),
                        ),
                        child: Text(
                          gender.toUpperCase(),
                          style: TextStyle(fontFamily: 'RobotoMono', color: color, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen, color: color, size: 20),
                      onPressed: onFullscreenToggle,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Panel content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (status != null && status.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                        child: Text(
                          "⚙️ BEAM: $status",
                          style: TextStyle(
                            color: color.withOpacity(0.6),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          content.isEmpty ? '// Awaiting input...' : content,
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: content.isEmpty ? const Color(0xFF484F58) : const Color(0xFFC9D1D9),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Audio player footer
              if (content.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFF21262D), width: 1)),
                    color: Color(0xFF0D1117),
                  ),
                  child: GestureDetector(
                    onTap: () => _replayAudio(isFirstSide),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          color: color.withOpacity(0.7),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '// replay audio',
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: color.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.volume_up_outlined,
                          color: color.withOpacity(0.4),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // Waveform Overlay (Optimized: No Global Rebuild)
          if (isRecording || (isFirstSide ? (isAudioPlaying && transcription1.isNotEmpty) : (isAudioPlaying && transcription2.isNotEmpty)))
            Positioned(
              bottom: 8,
              left: 12,
              right: 12,
              height: 30,
              child: IgnorePointer(
                child: Container(
                  child: Center(
                    child: Text("// active", style: TextStyle(color: color.withOpacity(0.3), fontSize: 8)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String label,
    required bool isRecording,
    required VoidCallback onStart,
    required VoidCallback onStop,
    required Color color,
  }) {
    return Listener(
      onPointerDown: (_) => onStart(),
      onPointerUp: (_) => onStop(),
      onPointerCancel: (_) => onStop(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRecording ? color.withOpacity(0.2) : const Color(0xFF21262D),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isRecording ? color : const Color(0xFF30363D),
            width: isRecording ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Subtle language indicator (small, discrete)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "// ${label.toLowerCase()}",
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    color: color.withOpacity(0.6),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.mic_none_outlined,
                  color: color.withOpacity(0.4),
                  size: 12,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Main action
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isRecording ? Icons.fiber_manual_record : Icons.radio_button_unchecked,
                  color: isRecording ? color : const Color(0xFF8B949E),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isRecording ? "recording..." : "hold to speak",
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    color: isRecording ? color : const Color(0xFF8B949E),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _mergeWavFiles(List<String> filePaths) async {
    return null;
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  WaveformPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final double width = size.width;
    final double height = size.height;
    final double spacing = width / (data.isEmpty ? 1 : data.length);

    for (int i = 0; i < data.length; i++) {
        double x = i * spacing;
        double barHeight = data[i] * height;
        canvas.drawLine(Offset(x, height / 2 - barHeight / 2), Offset(x, height / 2 + barHeight / 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WaveHeader {
  static Uint8List addWavHeader(List<int> pcmData, int sampleRate, int numChannels, int bitsPerSample) {
    final int headerSize = 44;
    final int dataSize = pcmData.length;
    final int fileSize = dataSize + headerSize - 8;
    final int byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    final int blockAlign = numChannels * bitsPerSample ~/ 8;

    final header = ByteData(headerSize);

    // RIFF header
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, fileSize, Endian.little);
    header.setUint8(8, 0x57); // W
    header.setUint8(9, 0x41); // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E

    // fmt chunk
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6d); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // space
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);

    // data chunk
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, dataSize, Endian.little);

    final wav = Uint8List(headerSize + dataSize);
    wav.setAll(0, header.buffer.asUint8List());
    wav.setAll(headerSize, pcmData is Uint8List ? pcmData : Uint8List.fromList(pcmData));
    return wav;
  }
}
