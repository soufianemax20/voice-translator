import 'package:flutter/foundation.dart';
import '../services/elevenlabs_service.dart';
import '../services/aws_translate_service.dart';
import '../models/language.dart';

class TranslationProvider with ChangeNotifier {
  final ElevenLabsService _elevenLabs = ElevenLabsService();
  final AWSTranslateService _awsTranslate = AWSTranslateService();

  // Speaker 1
  Language _speaker1Language = Language.english;
  String _speaker1Gender = 'male';
  String _speaker1Text = '';
  String _speaker1TranslatedText = '';
  bool _speaker1IsRecording = false;

  // Speaker 2
  Language _speaker2Language = Language.spanish;
  String _speaker2Gender = 'female';
  String _speaker2Text = '';
  String _speaker2TranslatedText = '';
  bool _speaker2IsRecording = false;

  // Status
  bool _isTranslating = false;
  bool _isSpeaking = false;
  String _statusMessage = 'Ready to Translate';

  // Getters
  Language get speaker1Language => _speaker1Language;
  String get speaker1Gender => _speaker1Gender;
  String get speaker1Text => _speaker1Text;
  String get speaker1TranslatedText => _speaker1TranslatedText;
  bool get speaker1IsRecording => _speaker1IsRecording;

  Language get speaker2Language => _speaker2Language;
  String get speaker2Gender => _speaker2Gender;
  String get speaker2Text => _speaker2Text;
  String get speaker2TranslatedText => _speaker2TranslatedText;
  bool get speaker2IsRecording => _speaker2IsRecording;

  bool get isTranslating => _isTranslating;
  bool get isSpeaking => _isSpeaking;
  String get statusMessage => _statusMessage;

  /// Set speaker 1 language
  void setSpeaker1Language(Language language) {
    _speaker1Language = language;
    notifyListeners();
  }

  /// Set speaker 1 gender
  void setSpeaker1Gender(String gender) {
    _speaker1Gender = gender;
    notifyListeners();
  }

  /// Set speaker 2 language
  void setSpeaker2Language(Language language) {
    _speaker2Language = language;
    notifyListeners();
  }

  /// Set speaker 2 gender
  void setSpeaker2Gender(String gender) {
    _speaker2Gender = gender;
    notifyListeners();
  }

  /// Swap languages between speakers
  void swapLanguages() {
    final tempLang = _speaker1Language;
    final tempGender = _speaker1Gender;
    final tempText = _speaker1Text;
    final tempTranslated = _speaker1TranslatedText;

    _speaker1Language = _speaker2Language;
    _speaker1Gender = _speaker2Gender;
    _speaker1Text = _speaker2Text;
    _speaker1TranslatedText = _speaker2TranslatedText;

    _speaker2Language = tempLang;
    _speaker2Gender = tempGender;
    _speaker2Text = tempText;
    _speaker2TranslatedText = tempTranslated;

    notifyListeners();
  }

  /// Set speaker 1 recording status
  void setSpeaker1Recording(bool isRecording) {
    _speaker1IsRecording = isRecording;
    _speaker2IsRecording = false; // Only one speaker can record at a time
    notifyListeners();
  }

  /// Set speaker 2 recording status
  void setSpeaker2Recording(bool isRecording) {
    _speaker2IsRecording = isRecording;
    _speaker1IsRecording = false; // Only one speaker can record at a time
    notifyListeners();
  }

  /// Process audio for Speaker 1
  Future<void> processSpeaker1Audio(Uint8List audioBytes) async {
    try {
      _isTranslating = true;
      _statusMessage = 'Transcribing...';
      notifyListeners();

      // Speech to Text
      final transcript = await _elevenLabs.speechToText(
        audioBytes: audioBytes,
        languageCode: _speaker1Language.code,
      );

      if (transcript == null || transcript.isEmpty) {
        _statusMessage = 'Failed to transcribe audio';
        _isTranslating = false;
        notifyListeners();
        return;
      }

      _speaker1Text = transcript;
      _statusMessage = 'Translating...';
      notifyListeners();

      // Translate
      final translated = await _awsTranslate.translateText(
        text: transcript,
        sourceLang: _speaker1Language.code,
        targetLang: _speaker2Language.code,
      );

      if (translated == null || translated.isEmpty) {
        _statusMessage = 'Failed to translate';
        _isTranslating = false;
        notifyListeners();
        return;
      }

      _speaker2TranslatedText = translated;
      _statusMessage = 'Generating speech...';
      notifyListeners();

      // Text to Speech
      final audioData = await _elevenLabs.textToSpeech(
        text: translated,
        languageCode: _speaker2Language.code,
        gender: _speaker2Gender,
      );

      _isTranslating = false;
      _statusMessage = 'Ready to Translate';
      notifyListeners();

      // Play audio will be handled by AudioProvider
      if (audioData != null) {
        // Signal that audio is ready
        _isSpeaking = true;
        notifyListeners();
      }

    } catch (e) {
      print('❌ Error processing speaker 1 audio: $e');
      _statusMessage = 'Error: $e';
      _isTranslating = false;
      notifyListeners();
    }
  }

  /// Process audio for Speaker 2
  Future<void> processSpeaker2Audio(Uint8List audioBytes) async {
    try {
      _isTranslating = true;
      _statusMessage = 'Transcribing...';
      notifyListeners();

      // Speech to Text
      final transcript = await _elevenLabs.speechToText(
        audioBytes: audioBytes,
        languageCode: _speaker2Language.code,
      );

      if (transcript == null || transcript.isEmpty) {
        _statusMessage = 'Failed to transcribe audio';
        _isTranslating = false;
        notifyListeners();
        return;
      }

      _speaker2Text = transcript;
      _statusMessage = 'Translating...';
      notifyListeners();

      // Translate
      final translated = await _awsTranslate.translateText(
        text: transcript,
        sourceLang: _speaker2Language.code,
        targetLang: _speaker1Language.code,
      );

      if (translated == null || translated.isEmpty) {
        _statusMessage = 'Failed to translate';
        _isTranslating = false;
        notifyListeners();
        return;
      }

      _speaker1TranslatedText = translated;
      _statusMessage = 'Generating speech...';
      notifyListeners();

      // Text to Speech
      final audioData = await _elevenLabs.textToSpeech(
        text: translated,
        languageCode: _speaker1Language.code,
        gender: _speaker1Gender,
      );

      _isTranslating = false;
      _statusMessage = 'Ready to Translate';
      notifyListeners();

      // Play audio will be handled by AudioProvider
      if (audioData != null) {
        _isSpeaking = true;
        notifyListeners();
      }

    } catch (e) {
      print('❌ Error processing speaker 2 audio: $e');
      _statusMessage = 'Error: $e';
      _isTranslating = false;
      notifyListeners();
    }
  }

  /// Clear all texts
  void clearAll() {
    _speaker1Text = '';
    _speaker1TranslatedText = '';
    _speaker2Text = '';
    _speaker2TranslatedText = '';
    _statusMessage = 'Ready to Translate';
    notifyListeners();
  }
}
