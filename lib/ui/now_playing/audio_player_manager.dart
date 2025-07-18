import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerManager {
  AudioPlayerManager({required this.songUrl});

  final player = AudioPlayer();
  Stream<DurationState>? durationState;
  String songUrl;

  void init() {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      player.positionStream,              // Stream phát ra thời gian đã phát
      player.playbackEventStream,         // Stream phát ra sự kiện phát lại (bao gồm buffered và total duration)
          (position, playbackEvent) => DurationState(
        progress: position,                         // thời gian đã phát
        buffered: playbackEvent.bufferedPosition,   // thời gian đã tải (buffered)
        total: playbackEvent.duration,              // tổng thời lượng
      ),
    );

    player.setUrl(songUrl); // Thiết lập URL bài hát để phát
  }

  void dispose(){
    player.dispose();

  }

}

class DurationState {
  // Constructor (Ham khoi tao )
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });

  // Thoi luong phat
  final Duration progress;

  // Thoi luong da duoc tai truoc
  final Duration buffered;

  // Tong toi luong co the null nen chua biet
  final Duration? total;
}
