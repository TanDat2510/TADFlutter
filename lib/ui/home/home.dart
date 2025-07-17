import 'package:appfirst2025/ui/discovery/discovey.dart';
import 'package:appfirst2025/ui/home/viewmodel.dart';
import 'package:appfirst2025/ui/settings/settings.dart';
import 'package:appfirst2025/ui/user/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/model/song.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({
    super.key,
  }); // truyen key cho widget cha (Flutter su dung de kiem soat

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZingMP5',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MusicHomePage(), // khi chay app, homepage se duoc hien thi
    );
  }
}
class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key}); // giao dien chinh man hinh co tab hien thi

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveyTab(),
    const AccountTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('MusicApp')),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.album),
              label: 'Discovery',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Setting',
            ),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late MusicViewModel _viewModel = MusicViewModel();

  @override
  void initState() {
    //khoi tao thanh phan
    _viewModel = MusicViewModel();
    _viewModel.loadSongs();
    observeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //giao dien khung suon chinh
    return Scaffold(body: getBody());
  }

  @override
  void dispose() {
    //giai phong bo nho
    _viewModel.songStream.close();
    super.dispose();
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      //neu showLoading khong co gi het
      return getProgressBar();
    } else
      return getListView();
  }


  Widget getProgressBar() {
    return const Center(
      // can giua noi dung ben trong ca chieu ngang va chieu doc
      child:
          CircularProgressIndicator(), // vong trong loading mac dinh cua Flutter
    );
  }

  ListView getListView() {
    //dung separated de tao duong phan cach giua cac ban nhac
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey, //Mau cua duong phan cach
          thickness: 1, // do day
          indent: 24, //khoang cach le trai
          endIndent: 24, // khoang cach le phai
        );
      },
      itemCount: songs.length,
      shrinkWrap: true, //tao thanh cuon cho listview
    );
  }

  Widget getRow(int index) {
    return Center(
      child:Text(songs[index].title) //tra ve ten cua bai hat ,
    );
  }

  void observeData() {
    //Lay du lieu tu trong songStream
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }
}


class _songItemSection{
  //final _HomeTabPageState parent;
}
