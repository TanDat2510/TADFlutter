import 'dart:math';

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
  //bien khoi tao tre
  late AnimationController _imageAnimController;
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _song;
  late double _currentAnimationPosition;
  bool _isShuffle = false;
  bool _isRepeat = false;
  late LoopMode _loopMode;

  @override
  void initState() {
    super.initState();
    _currentAnimationPosition=0.0;
    _song=widget.playingSong;
    _imageAnimController = AnimationController(
      //dung de dieuu khien animation
      vsync: this,
      duration: const Duration(
        milliseconds: 12000,
      ), //animation se chay trong 12s
    );
    _audioPlayerManager = AudioPlayerManager(
      songUrl: _song.source,
    );
    _audioPlayerManager.init();
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);//lay vi tri cua bai hang trong danh sah bai hat
    _loopMode = LoopMode.off;

  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
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
              Text(_song.album),
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
                    image: _song.image,
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
                        color: Theme
                            .of(context)
                            .colorScheme
                            .primary,
                      ),
                      Column(
                        children: [
                          Text(
                            _song.title,
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                              color: Theme
                                  .of(
                                context,
                              )
                                  .textTheme
                                  .bodyMedium!
                                  .color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _song.artist,
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                              color: Theme
                                  .of(
                                context,
                              )
                                  .textTheme
                                  .bodyMedium!
                                  .color,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.favorite_outlined),
                        color: Theme
                            .of(context)
                            .colorScheme
                            .primary,
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
    _audioPlayerManager.dispose(); // Khi thoat ra khoi man hinh bai hat se duoc tat di
    _imageAnimController.dispose();
    super.dispose();
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
            function: _setShuffle,
            icon: Icons.shuffle,
            color: _getShuffleColor(),
            size: 24,
          ),
          MediaButtonControl(
            function: _setPrevSong,
            icon: Icons.skip_previous,
            color: Colors.deepPurple,
            size: 36,
          ),
          _playButton(),
          MediaButtonControl(
            function: _setNextSong,
            icon: Icons.skip_next,
            color: Colors.deepPurple,
            size: 36,
          ),
          MediaButtonControl(
            function: _setRepatOption,
            icon: _repeatingIcon(),
            color: _getRepeatingIconColor(),
            size: 24  ,
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
        return ProgressBar(
            progress: progress,
            total: total,
            buffered: buffered,
            //bo dem
            onSeek: _audioPlayerManager.player.seek,
            //gan callback function cho su keo keo xa audio
            progressBarColor: Colors.blue,
            thumbColor: Colors.deepPurple
        );
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
              _audioPlayerManager.player.play(); //hanh dong start hoat resum
              _imageAnimController.forward(from: _currentAnimationPosition);
              _imageAnimController.repeat();
            },
            icon: Icons.play_arrow,
            color: Colors.black,
            size: 48,
          );
        } else if (processingState != ProcessingState.completed) {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.pause();
              _imageAnimController.stop();
              _currentAnimationPosition=_imageAnimController.value;
            },
            icon: Icons.pause,
            color: Colors.black,
            size: 48,
          );
        } else {
          //truong hop cuoi if song complete -> stop and reset
          if(processingState==ProcessingState.completed){
            _imageAnimController.stop();
            _currentAnimationPosition=0.0;
          }
          return MediaButtonControl(
            function: () {
              _currentAnimationPosition=0.0;
              _imageAnimController.forward(from: _currentAnimationPosition);
              _imageAnimController.repeat();
              _audioPlayerManager.player.seek(
                Duration.zero,
              );
            },
            icon: Icons.replay,
            color: null,
            size: 48,
          );
        }
      },
    );
  }

  void _setNextSong(){
    if(_isShuffle){
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    }else if(_selectedItemIndex<widget.songs.length -1){
      ++_selectedItemIndex;
    }else if(_loopMode==LoopMode.all && _selectedItemIndex == widget.songs.length-1){
      _selectedItemIndex=0;
    }
    if(_selectedItemIndex > widget.songs.length){
      _selectedItemIndex=_selectedItemIndex % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    setState(() {
      _song = nextSong;
    });
  }

  void _setPrevSong(){
    if(_isShuffle){
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    }else if(_selectedItemIndex > 0){
      --_selectedItemIndex;
    } else if(_loopMode==LoopMode.all && _selectedItemIndex ==0){
      _selectedItemIndex = widget.songs.length -1;
    }
    if(_selectedItemIndex < 0){
      _selectedItemIndex=((-1)*_selectedItemIndex) % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    setState(() {
      _song = nextSong;
    });

  }

  void _setShuffle(){
    setState(() {
      _isShuffle=!_isShuffle;
    });


  }

  void _setRepatOption(){
    if (_loopMode==LoopMode.off){
      _loopMode = LoopMode.one;
    }else if(_loopMode==LoopMode.one){
      _loopMode = LoopMode.all;
    }else{
      _loopMode = LoopMode.off;
    }
    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
    });
  }

  Color? _getShuffleColor(){
    return _isShuffle ? Colors.deepPurple : Colors.grey;
  }

  IconData _repeatingIcon(){
    return switch(_loopMode){
      LoopMode.one =>  Icons.repeat_one,
    LoopMode.all => Icons.repeat_on,
    _ => Icons.repeat,
    };
  }

  Color? _getRepeatingIconColor(){
    return _loopMode == LoopMode.off? Colors.grey: Colors.deepPurple;
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
        color: widget.color ?? Theme
            .of(context)
            .colorScheme
            .primary,
        size: widget.size,
      ),
    );
  }
}
