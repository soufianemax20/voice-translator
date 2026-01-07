import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';

class MobileAudioRecorder {
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamController<Uint8List>? _audioStreamController;
  StreamSubscription? _audioSubscription;

  Stream<Uint8List> get audioStream => _audioStreamController!.stream;

  Future<bool> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        _audioStreamController = StreamController<Uint8List>();
        
        final stream = await _audioRecorder.startStream(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ),
        );

        _audioSubscription = stream.listen((data) {
          _audioStreamController?.add(data);
        });

        return true;
      }
      return false;
    } catch (e) {
      print('Erreur enregistrement mobile: $e');
      return false;
    }
  }

  Future<void> stopRecording() async {
    try {
      await _audioRecorder.stop();
      await _audioSubscription?.cancel();
      await _audioStreamController?.close();
    } catch (e) {
      print('Erreur arret enregistrement: $e');
    }
  }

  void dispose() {
    stopRecording();
    _audioRecorder.dispose();
  }
}
