import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  late AudioPlayer _audioPlayer;
  String? _currentUrl;

  factory AudioPlayerService() {
    return _instance;
  }

  AudioPlayerService._internal() {
    _audioPlayer = AudioPlayer();
  }

  AudioPlayer get player => _audioPlayer;
  String? get currentUrl => _currentUrl;

  Future<void> playAudio(String audioUrl) async {
    try {
      // If the same track completed, seek to start instead of reloading
      if (_currentUrl == audioUrl &&
          _audioPlayer.processingState == ProcessingState.completed) {
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.play();
        return;
      }
      _currentUrl = audioUrl;
      // Call play() before setUrl() — just_audio emits playing:true immediately
      // and auto-starts as soon as the source is buffered, so the UI responds
      // without waiting for the network.
      final playFuture = _audioPlayer.play();
      if (audioUrl.startsWith('http://') || audioUrl.startsWith('https://')) {
        await _audioPlayer.setUrl(audioUrl);
      } else {
        await _audioPlayer.setAsset(audioUrl);
      }
      await playFuture;
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> resumeAudio() async {
    await _audioPlayer.play();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}