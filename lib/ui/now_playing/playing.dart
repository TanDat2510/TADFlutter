import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/model/song.dart';
import 'audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(songs: songs, playingSong: playingSong);
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({
    super.key,
    required this.songs,
    required this.playingSong,
  });

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimController;
  late AudioPlayerManager _audioPlayerManager;

  @override
  void initState() {
    super.initState();
    _imageAnimController = AnimationController(
      //dung de dieuu khien animation
      vsync: this,
      duration: const Duration(
        milliseconds: 12000,
      ), //animation se chay trong 12s
    );
    _audioPlayerManager = AudioPlayerManager(
      songUrl: widget.playingSong.source,
    );
    _audioPlayerManager.init();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Now Playing'),
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz),
        ),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.playingSong.album),
              const SizedBox(height: 16),
              const Text('_ ___ _'),
              const SizedBox(height: 48),
              RotationTransition(
                turns: Tween(
                  begin: 0.0,
                  end: 1.0,
                ).animate(_imageAnimController),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/logo.png',
                    image: widget.playingSong.image,
                    width: screenWidth - delta,
                    height: screenWidth - delta,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/logo.png',
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 64, bottom: 16),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Column(
                        children: [
                          Text(
                            widget.playingSong.title,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium!.color,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.playingSong.artist,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium!.color,
                                ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.favorite_outlined),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 24,
                  right: 24,
                  bottom: 10,
                ),
                child: _progressBar(),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 24,
                  right: 24,
                  bottom: 10,
                ),
                child: _mediaButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayerManager
      ..dispose(); // Khi thoat ra khoi man hinh bai hat se duoc tat di
    super.dispose();
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
            function: null,
            icon: Icons.shuffle,
            color: Colors.deepPurple,
            size: 24,
          ),
          MediaButtonControl(
            function: null,
            icon: Icons.skip_previous,
            color: Colors.deepPurple,
            size: 36,
          ),
          _playButton(),
          MediaButtonControl(
            function: null,
            icon: Icons.skip_next,
            color: Colors.deepPurple,
            size: 36,
          ),
          MediaButtonControl(
            function: null,
            icon: Icons.repeat,
            color: Colors.deepPurple,
            size: 36,
          ),
        ],
      ),
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      stream: _audioPlayerManager.durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;
        return ProgressBar(progress: progress, total: total);
      },
    );
  }

  // cap nhat UI dua tren du lieu moi tu mot Stream
  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
      stream: _audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState =
            playState?.processingState; // trang thai qua trinh
        final playing = playState?.playing; //trang thai co dang phat hay khong

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8),
            width: 48,
            height: 48,
            child: const CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.play();//hanh dong
            },
            icon: Icons.play_arrow,
            color: Colors.black,
            size: 48,
          );
        } else if (processingState != ProcessingState.completed) {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.pause();
            },
            icon: Icons.pause,
            color: Colors.black,
            size: 48,
          );
        } else {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.seek(Duration.zero);// chuc nang xa chua thuc hien duoc.
            },
            icon: Icons.replay,
            color: null,
            size: 48,
          );
        }
      },
    );
  }
}

// Widget co the thay doi trang thai
class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function, //hanh dong nhan nut
    required this.icon,
    required this.color,
    required this.size,
  });

  //thuoc tinh truyen vao ben ngoai khi tao widget
  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  // tao mot instance noi de xay duung giao dien
  @override
  State<MediaButtonControl> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(
        widget.icon,
        color: widget.color ?? Theme.of(context).colorScheme.primary,
        size: widget.size,
      ),
    );
  }
}
