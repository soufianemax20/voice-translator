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
  String _currentLanguage = 'auto';

  void start(String languageCode) {
    _isActive = true;
    _audioBuffer.clear();
    _currentLanguage = languageCode;
    
    // Recréer le StreamController s'il a été fermé
    if (_transcriptController.isClosed) {
      _transcriptController.close(); // Juste au cas où
      // On ne peut pas recréer, utilisons une nouvelle instance
    }
    
    print('✅ Scribe V2 Service started for language: $languageCode');
    
    // Transcription temps réel : envoyer des chunks toutes les 2 secondes
    _processingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_audioBuffer.length >= 32000 && _isActive) { // Au moins 1 seconde d'audio
        _processAudioChunk(languageCode);
      }
    });
  }

  void addAudioChunk(List<int> audioChunk) {
    if (_isActive) {
      _audioBuffer.addAll(audioChunk);
    }
  }
  
  // Traiter un chunk pendant l'enregistrement (temps réel)
  Future<void> _processAudioChunk(String languageCode) async {
    if (_audioBuffer.length < 32000) return; // Min 1 sec d'audio
    
    try {
      // Prendre seulement les dernières 3 secondes (96000 bytes)
      final chunkSize = _audioBuffer.length > 96000 ? 96000 : _audioBuffer.length;
      final audioData = Uint8List.fromList(_audioBuffer.sublist(_audioBuffer.length - chunkSize));
      
      // Ne pas vider le buffer (on garde pour la transcription finale)
      
      final wavFile = _createWavFile(audioData);
      
      final url = Uri.parse('$_baseUrl/speech-to-text');
      var request = http.MultipartRequest('POST', url);
      request.headers['xi-api-key'] = _apiKey;
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          wavFile,
          filename: 'audio.wav',
          contentType: MediaType('audio', 'wav'),
        ),
      );
      
      request.fields['model_id'] = 'scribe_v2';
      
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('STT timeout'),
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final utf8Body = utf8.decode(response.bodyBytes);
        final data = jsonDecode(utf8Body);
        final text = data['text']?.toString().trim() ?? '';
        
        if (text.isNotEmpty) {
          print('🔄 Temps réel: $text');
          
          try {
            _transcriptController.add(text);
          } catch (e) {
            // Ignore si fermé
          }
        }
      }
    } catch (e) {
      // Ignore les erreurs de chunks intermédiaires
    }
  }

  // Fonction pour créer un header WAV valide (44 bytes)
  Uint8List _createWavFile(Uint8List pcmData) {
    final int dataSize = pcmData.length;
    final int fileSize = 36 + dataSize;
    
    final header = ByteData(44);
    
    // RIFF header
    header.setUint8(0, 0x52); // 'R'
    header.setUint8(1, 0x49); // 'I'
    header.setUint8(2, 0x46); // 'F'
    header.setUint8(3, 0x46); // 'F'
    header.setUint32(4, fileSize, Endian.little);
    
    // WAVE header
    header.setUint8(8, 0x57);  // 'W'
    header.setUint8(9, 0x41);  // 'A'
    header.setUint8(10, 0x56); // 'V'
    header.setUint8(11, 0x45); // 'E'
    
    // fmt subchunk
    header.setUint8(12, 0x66); // 'f'
    header.setUint8(13, 0x6D); // 'm'
    header.setUint8(14, 0x74); // 't'
    header.setUint8(15, 0x20); // ' '
    header.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    header.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
    header.setUint16(22, 1, Endian.little);  // NumChannels (1 = mono)
    header.setUint32(24, 16000, Endian.little); // SampleRate (16kHz)
    header.setUint32(28, 32000, Endian.little); // ByteRate (SampleRate * NumChannels * BitsPerSample/8)
    header.setUint16(32, 2, Endian.little);  // BlockAlign (NumChannels * BitsPerSample/8)
    header.setUint16(34, 16, Endian.little); // BitsPerSample (16-bit)
    
    // data subchunk
    header.setUint8(36, 0x64); // 'd'
    header.setUint8(37, 0x61); // 'a'
    header.setUint8(38, 0x74); // 't'
    header.setUint8(39, 0x61); // 'a'
    header.setUint32(40, dataSize, Endian.little);
    
    // Combiner header + data
    final wavFile = Uint8List(44 + dataSize);
    wavFile.setRange(0, 44, header.buffer.asUint8List());
    wavFile.setRange(44, 44 + dataSize, pcmData);
    
    return wavFile;
  }

  Future<void> _processAudioBuffer(String languageCode) async {
    if (_audioBuffer.isEmpty) return;
    
    try {
      final pcmData = Uint8List.fromList(_audioBuffer);
      _audioBuffer.clear();
      
      // Convertir PCM brut en fichier WAV avec header
      final wavFile = _createWavFile(pcmData);
      
      print('🔄 Processing ${wavFile.length} bytes WAV (${pcmData.length} PCM) with 11Labs STT...');
      
      final url = Uri.parse('$_baseUrl/speech-to-text');
      
      var request = http.MultipartRequest('POST', url);
      request.headers['xi-api-key'] = _apiKey;
      
      // Créer le fichier audio avec le bon content-type
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          wavFile,
          filename: 'audio.wav',
          contentType: MediaType('audio', 'wav'),
        ),
      );
      
      // Ajouter les paramètres optionnels
      request.fields['model_id'] = 'scribe_v2';
      
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('⏱️ STT request timeout');
          throw TimeoutException('STT timeout');
        },
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        // Forcer UTF-8 pour éviter la corruption des accents
        final utf8Body = utf8.decode(response.bodyBytes);
        final data = jsonDecode(utf8Body);
        final text = data['text']?.toString().trim() ?? '';
        
        if (text.isNotEmpty) {
          print('✅ Scribe transcription: $text');
          
          try {
            _transcriptController.add(text);
          } catch (e) {
            print('⚠️ Cannot add to stream: $e');
          }
        } else {
          print('⚠️ Empty transcription received');
        }
      } else {
        print('❌ STT error ${response.statusCode}: ${response.body}');
        
        // Si erreur 400, vérifier le format audio
        if (response.statusCode == 400) {
          print('💡 Tip: Vérifiez que l\'audio est correct (16kHz mono PCM)');
        }
      }
    } catch (e) {
      print('❌ STT exception: $e');
    }
  }

  void stop() async {
    _isActive = false;
    _processingTimer?.cancel();
    
    // Traiter TOUTE la phrase accumulée
    if (_audioBuffer.isNotEmpty) {
      print('🎯 Attente de 500ms pour finaliser la capture...');
      
      // Délai pour s'assurer que tout l'audio est capturé
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('🎯 Envoi de la phrase complète (${_audioBuffer.length} bytes)...');
      await _processAudioBuffer(_currentLanguage);
    }
    
    print('🛑 Scribe V2 Service stopped');
  }

  void dispose() {
    stop();
    _transcriptController.close();
  }

}
