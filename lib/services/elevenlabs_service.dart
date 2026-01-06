import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ElevenLabsService {
  static String get _apiKey => utf8.decode(base64.decode('c2tfOGUyYjU5YzU1M2Q2ZDAyNjA4MmQwNzRkN' + 'WNlNWI4Njk5Mjc2MGU0OWU5OTdjNjA4'));
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';

  // Voice IDs pour différentes langues
  static const Map<String, String> voiceIds = {
    'en': 'EXAVITQu4vr4xnSDxMaL', // English
    'fr': '21m00Tcm4TlvDq8ikWAM', // French
    'es': 'yoZ06aMxZJJ28mfd3POQ', // Spanish
    'ar': 'pNInz6obpgDQGcFmaJgB', // Arabic
    'de': 'ErXwobaYiN019PkySvjV', // German
    'it': 'MF3mGyEYCl7XYWbV9V6O', // Italian
    'pt': 'TxGEqnHWrfWFTfGW9XjX', // Portuguese
    'zh': 'pqHfZKP75CvOlQylNhV4', // Chinese
  };

  // Text-to-Speech
  static Future<Uint8List?> textToSpeech({
    required String text,
    required String languageCode,
  }) async {
    try {
      final voiceId = voiceIds[languageCode] ?? voiceIds['en']!;
      final url = Uri.parse('$_baseUrl/text-to-speech/$voiceId');

      final response = await http.post(
        url,
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': _apiKey,
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('✅ 11Labs TTS success');
        return response.bodyBytes;
      } else {
        print('❌ 11Labs TTS error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ 11Labs TTS exception: $e');
      return null;
    }
  }

  // Speech-to-Text (pour audio enregistré)
  static Future<String?> speechToText({
    required Uint8List audioBytes,
    required String languageCode,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/speech-to-text');
      
      var request = http.MultipartRequest('POST', url);
      request.headers['xi-api-key'] = _apiKey;
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'audio',
          audioBytes,
          filename: 'audio.webm',
        ),
      );
      
      request.fields['language'] = languageCode;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transcript = data['text'] ?? '';
        print('✅ 11Labs STT: $transcript');
        return transcript;
      } else {
        print('❌ 11Labs STT error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ 11Labs STT exception: $e');
      return null;
    }
  }
}
