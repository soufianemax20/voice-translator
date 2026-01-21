import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class BeamAiService {
  static const String _endpointUrl = 'https://tgpro1-s2st.hf.space/api/v1/process';
  
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 300),
    receiveTimeout: const Duration(seconds: 300),
  ));

  void _log(String message) {
    debugPrint("🚀 [HF Space] $message");
  }

  /// Direct API call (FastAPI mode)
  Future<Map<String, dynamic>?> _callDirectAPI(Map<String, dynamic> request) async {
    final String action = request['action'] ?? 'unknown';
    try {
      _log("Sending '$action' request to HF Space...");
      final response = await _dio.post(
        _endpointUrl,
        data: request, // Direct JSON, no wrapper
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        _log("Received 200 OK for '$action'");
        return response.data;
      } else {
        _log("Unexpected response for '$action': ${response.statusCode}");
      }
    } catch (e) {
      _log("API Error for '$action': $e");
    }
    return null;
  }

  /// 🧛 WAKE UP: Call this on app start to warm up the GPU
  Future<void> preWarmup() async {
    try {
      _log("Pre-warming GPU...");
      await _callDirectAPI({"action": "health"});
    } catch (_) {}
  }

  /// 🏥 Heartbeat: Ping the health endpoint directly (Lightweight CPU)
  Future<void> health() async {
    try {
      await _dio.get('https://tgpro1-s2st.hf.space/health');
    } catch (_) {}
  }

  /// 💓 ACTIVE HEARTBEAT: Deep ping that triggers a GPU session (Prevents deep sleep)
  Future<void> deepHeartbeat() async {
    try {
      _log("Sending deep heartbeat...");
      await _callDirectAPI({"action": "health"});
    } catch (_) {}
  }

  /// 🧹 CACHE CLEAR: Manually trigger backend cleanup
  Future<Map<String, dynamic>?> clearCache() async {
    try {
      _log("Triggering manual cache clear...");
      final response = await _dio.post('https://tgpro1-s2st.hf.space/api/v1/clear_cache');
      return response.data;
    } catch (e) {
      _log("Cache Clear Error: $e");
      return null;
    }
  }

  /// Transcription (STT) via Whisper
  Future<String?> transcribe(File audioFile, {String? lang}) async {
    try {
      _log("Starting Transcription... (Guidance: ${lang ?? 'auto'})");
      final bytes = await audioFile.readAsBytes();
      final base64Audio = base64Encode(bytes);

      final result = await _callDirectAPI({
        "action": "stt",
        "file": base64Audio,
        if (lang != null) "lang": lang,
      });

      if (result != null && result['text'] != null) {
        _log("Transcription Successful: ${result['text']}");
        return result['text'];
      }
    } catch (e) {
      _log("STT Error: $e");
    }
    return null;
  }

  /// Translation via NLLB-200
  Future<String?> translate(String text, String targetLang, {String? sourceLang}) async {
    try {
      _log("Starting Translation to $targetLang...");
      final result = await _callDirectAPI({
        "action": "translate",
        "text": text,
        "target_lang": targetLang,
        if (sourceLang != null) "source_lang": sourceLang,
      });

      if (result != null && result['translated'] != null) {
        _log("Translation Successful");
        return result['translated'];
      }
    } catch (e) {
      _log("Translation Error: $e");
    }
    return null;
  }

  /// Unified Speech-to-Speech (S2ST) - One hop for best quality
  Future<Map<String, dynamic>?> s2st(File audioFile, String targetLang, {String? sourceLang, File? speakerRef}) async {
    try {
      _log("🚀 Starting Unified S2ST chain to $targetLang...");
      final audioBytes = await audioFile.readAsBytes();
      final base64Audio = base64Encode(audioBytes);

      String? speakerWavBase64;
      if (speakerRef != null) {
        speakerWavBase64 = base64Encode(await speakerRef.readAsBytes());
      }

      final result = await _callDirectAPI({
        "action": "s2st",
        "file": base64Audio,
        "source_lang": sourceLang,
        "target_lang": targetLang,
        if (speakerWavBase64 != null) "speaker_wav": speakerWavBase64,
      });

      return result;
    } catch (e) {
      _log("S2ST Error: $e");
    }
    return null;
  }

  /// Text-to-Speech (TTS) via XTTS-v2
  Future<Uint8List?> synthesize(String text, String targetLang, {File? inputAudio}) async {
    try {
      _log("Starting TTS for '$text'...");
      
      String? speakerWavBase64;
      if (inputAudio != null) {
        speakerWavBase64 = base64Encode(await inputAudio.readAsBytes());
      }

      final result = await _callDirectAPI({
        "action": "tts",
        "text": text,
        "lang": targetLang,
        if (speakerWavBase64 != null) "speaker_wav": speakerWavBase64,
      });

      if (result != null && result['audio'] != null) {
        _log("TTS Successful");
        return base64Decode(result['audio']);
      }
    } catch (e) {
      _log("TTS Error: $e");
    }
    return null;
  }

  /// Real-time TTS Stream (v66)
  Future<Stream<List<int>>?> streamTTS(String text, String targetLang, {File? inputAudio}) async {
    try {
      _log("🌊 [Stream] Starting TTS for '$text'...");
      
      String? speakerWavBase64;
      if (inputAudio != null) {
        speakerWavBase64 = base64Encode(await inputAudio.readAsBytes());
      }

      final response = await _dio.post(
        'https://tgpro1-s2st.hf.space/api/v1/tts_stream',
        data: {
          "text": text,
          "lang": targetLang,
          if (speakerWavBase64 != null) "speaker_wav": speakerWavBase64,
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Content-Type': 'application/json'}
        ),
      );

      if (response.statusCode == 200) {
        return (response.data as ResponseBody).stream;
      }
    } catch (e) {
      _log("TTS Stream Error: $e");
    }
    return null;
  }
}
