import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class StudySong {
  final String title;
  final String description;
  final String assetPath;

  const StudySong({
    required this.title,
    required this.description,
    required this.assetPath,
  });
}

class StudyProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  int? _currentTrackIndex;
  PlayerState _playerState = PlayerState.stopped;

  // formatted for audioplayers v6:

  final List<StudySong> _playlist = [
    const StudySong(
      title: "Calm Rain",
      description: "Soft rain drops for deep focus",
      assetPath: "audio/rain.mp3",
    ),
    const StudySong(
      title: "Ocean Waves",
      description: "Relaxing natural shoreline rhythm",
      assetPath: "audio/waves.mp3",
    ),
    const StudySong(
      title: "Morning Birds",
      description: "Peaceful ambient morning forest sounds",
      assetPath: "audio/birds.mp3",
    ),
  ];

  List<StudySong> get playlist => _playlist;
  int? get currentTrackIndex => _currentTrackIndex;
  bool get isPlaying => _playerState == PlayerState.playing;

  StudyProvider() {
    // native player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _playerState = state;
      notifyListeners();
    });

    // background ambiance looping seamlessly
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> togglePlayPause(int index) async {
    try {
      if (_currentTrackIndex == index) {
        if (isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.resume();
        }
      } else {
        _currentTrackIndex = index;
        await _audioPlayer.stop();

        // AssetSource natively resolves paths relative to the assets/ directory
        await _audioPlayer.play(AssetSource(_playlist[index].assetPath));
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error playing audio asset: $e");
    }
  }

  Future<void> pauseForBreak() async {
    await _audioPlayer.pause();
  }

  Future<void> resumeForStudy() async {
    if (_currentTrackIndex != null) {
      await _audioPlayer.resume();
    }
  }

  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    _currentTrackIndex = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}