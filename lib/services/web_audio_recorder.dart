import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

class WebAudioRecorder {
  html.MediaStream? _mediaStream;
  html.MediaRecorder? _mediaRecorder;
  final List<html.Blob> _audioChunks = [];
  final StreamController<Uint8List> _audioController = StreamController<Uint8List>.broadcast();

  Stream<Uint8List> get audioStream => _audioController.stream;
  bool get isRecording => _mediaRecorder?.state == 'recording';

  Future<bool> startRecording() async {
    try {
      // Demander permission microphone
      _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'sampleRate': 16000,
        }
      });

      _mediaRecorder = html.MediaRecorder(_mediaStream!, {
        'mimeType': 'audio/webm;codecs=opus',
      });

      _audioChunks.clear();

      // Écouter les données en temps réel pendant l'enregistrement
      _mediaRecorder!.addEventListener('dataavailable', (event) {
        final html.Event typedEvent = event;
        if (typedEvent is html.BlobEvent) {
          if (typedEvent.data != null && typedEvent.data!.size > 0) {
            _audioChunks.add(typedEvent.data!);
            
            // Convertir et streamer chaque chunk immédiatement
            final reader = html.FileReader();
            reader.onLoadEnd.listen((e) {
              final audioData = reader.result as Uint8List;
              _audioController.add(audioData);
            });
            reader.readAsArrayBuffer(typedEvent.data!);
          }
        }
      });

      _mediaRecorder!.start(100); // Enregistrer par chunks de 100ms
      print('🎤 Recording started');
      return true;
    } catch (e) {
      print('❌ Recording error: $e');
      return false;
    }
  }

  Future<void> stopRecording() async {
    if (_mediaRecorder != null && _mediaRecorder!.state == 'recording') {
      _mediaRecorder!.stop();
      _mediaStream?.getTracks().forEach((track) => track.stop());
      print('🛑 Recording stopped');
    }
  }

  void dispose() {
    stopRecording();
    _audioController.close();
  }
}
