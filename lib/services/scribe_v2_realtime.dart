import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';

class ScribeV2Service {
  static String get _apiKey => utf8.decode(base64.decode('c2tfOGUyYjU5YzU1M2Q2ZDAyNjA4MmQwNzRkN' + 'WNlNWI4Njk5Mjc2MGU0OWU5OTdjNjA4'));
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  
  final StreamController<String> _transcriptController = StreamController<String>.broadcast();
  Stream<String> get transcriptStream => _transcriptController.stream;
  
  List<int> _audioBuffer = [];
  Timer? _processingTimer;
  bool _isActive = false;

  void start(String languageCode) {
    _isActive = true;
    _audioBuffer.clear();
    print('✅ Scribe V2 Service started for language: $languageCode');
    
    // Simuler le traitement en temps réel toutes les 2 secondes
    _processingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_audioBuffer.isNotEmpty && _isActive) {
        _processAudioBuffer(languageCode);
      }
    });
  }

  void addAudioChunk(List<int> audioChunk) {
    if (_isActive) {
      _audioBuffer.addAll(audioChunk);
    }
  }

  Future<void> _processAudioBuffer(String languageCode) async {
    if (_audioBuffer.isEmpty) return;
    
    try {
      final audioData = Uint8List.fromList(_audioBuffer);
      _audioBuffer.clear();
      
      print('🔄 Processing ${audioData.length} bytes with 11Labs STT...');
      
      final url = Uri.parse('$_baseUrl/speech-to-text');
      
      var request = http.MultipartRequest('POST', url);
      request.headers['xi-api-key'] = _apiKey;
      
      // Créer le fichier audio avec le bon content-type
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',  // Le paramètre doit s'appeler 'file'
          audioData,
          filename: 'audio.webm',
          contentType: MediaType('audio', 'webm'),
        ),
      );
      
      // Ajouter les paramètres optionnels
      request.fields['model_id'] = 'eleven_multilingual_v2';
      request.fields['language'] = languageCode;
      
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('⏱️ STT request timeout');
          throw TimeoutException('STT timeout');
        },
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['text']?.toString().trim() ?? '';
        
        if (text.isNotEmpty) {
          print('✅ Scribe transcription: $text');
          _transcriptController.add(text);
        } else {
          print('⚠️ Empty transcription received');
        }
      } else {
        print('❌ STT error ${response.statusCode}: ${response.body}');
        
        // Si erreur 400, peut-être que le format audio n'est pas supporté
        if (response.statusCode == 400) {
          print('💡 Tip: L\'API peut ne pas supporter le format WebM du navigateur');
        }
      }
    } catch (e) {
      print('❌ STT exception: $e');
    }
  }

  void stop() {
    _isActive = false;
    _processingTimer?.cancel();
    
    // Traiter le buffer restant
    if (_audioBuffer.isNotEmpty) {
      // On ne process pas le dernier buffer car il peut être incomplet
    }
    
    print('🛑 Scribe V2 Service stopped');
  }

  void dispose() {
    stop();
    _transcriptController.close();
  }
}
