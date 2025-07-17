import 'dart:async';

import 'package:appfirst2025/data/repository/repository.dart';

import '../../data/model/song.dart';

class MusicViewModel {
  StreamController<List<Song>> songStream = StreamController();

  void loadSongs(){//load data bai hat
    final repository = DefaultRepository();
    repository.loadData().then((value) => songStream.add(value!));
  }
}