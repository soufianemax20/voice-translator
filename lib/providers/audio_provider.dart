import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AudioProvider with ChangeNotifier {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  bool _hasPermission = false;
  String? _recordingPath;
  List<double> _waveformData = [];

  // Getters
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  bool get hasPermission => _hasPermission;
  List<double> get waveformData => _waveformData;

  AudioProvider() {
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
  }

  /// Request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    _hasPermission = status == PermissionStatus.granted;
    notifyListeners();
    return _hasPermission;
  }

  /// Check if permission is granted
  Future<bool> checkPermission() async {
    final status = await Permission.microphone.status;
    _hasPermission = status == PermissionStatus.granted;
    notifyListeners();
    return _hasPermission;
  }

  /// Start recording
  Future<bool> startRecording() async {
    try {
      if (!_hasPermission) {
        final granted = await requestPermission();
        if (!granted) {
          print('❌ Microphone permission denied');
          return false;
        }
      }

      if (await _audioRecorder.hasPermission()) {
        // Get temporary directory
        final directory = await getTemporaryDirectory();
        _recordingPath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            sampleRate: 44100,
            bitRate: 128000,
          ),
          path: _recordingPath!,
        );

        _isRecording = true;
        _startWaveformSimulation();
        notifyListeners();
        print('✅ Recording started');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error starting recording: $e');
      return false;
    }
  }

  /// Stop recording and return audio bytes
  Future<Uint8List?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      _waveformData = [];
      notifyListeners();

      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          print('✅ Recording stopped, size: ${bytes.length} bytes');
          return bytes;
        }
      }
      return null;
    } catch (e) {
      print('❌ Error stopping recording: $e');
      _isRecording = false;
      notifyListeners();
      return null;
    }
  }

  /// Play audio from bytes
  Future<void> playAudio(Uint8List audioBytes) async {
    try {
      // Stop any current playback
      await _audioPlayer.stop();

      // Save bytes to temp file
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/playback_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final file = File(filePath);
      await file.writeAsBytes(audioBytes);

      // Play the file
      await _audioPlayer.play(DeviceFileSource(filePath));
      print('✅ Playing audio');
    } catch (e) {
      print('❌ Error playing audio: $e');
    }
  }

  /// Stop audio playback
  Future<void> stopPlayback() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error stopping playback: $e');
    }
  }

  /// Simulate waveform data (in production, use actual audio stream)
  void _startWaveformSimulation() {
    Future.doWhile(() async {
      if (!_isRecording) return false;
      
      _waveformData = List.generate(
        50,
        (index) => (0.1 + (DateTime.now().millisecond % 100) / 100.0),
      );
      notifyListeners();
      
      await Future.delayed(const Duration(milliseconds: 100));
      return _isRecording;
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
