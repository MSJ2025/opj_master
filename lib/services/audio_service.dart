import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Future<void> playBackgroundMusic(String path) async {
    try {
      if (!_isPlaying) {
        print('🎵 Tentative de démarrage de la musique : $path');
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.setVolume(1.0); // Volume maximum
        await _audioPlayer.play(AssetSource(path));
        print('✅ Musique démarrée avec succès : $path');
        _isPlaying = true;
      } else {
        print('⚠️ La musique est déjà en cours de lecture');
      }
    } catch (e) {
      print('❌ Erreur lors du démarrage de la musique : $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        print('✅ Musique arrêtée');
        _isPlaying = false;
      } else {
        print('⚠️ Aucune musique à arrêter');
      }
    } catch (e) {
      print('❌ Erreur lors de l\'arrêt de la musique : $e');
    }
  }
}