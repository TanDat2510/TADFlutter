import 'package:appfirst2025/ui/discovery/discovery.dart';
import 'package:appfirst2025/ui/home/viewmodel.dart';
import 'package:appfirst2025/ui/settings/settings.dart';
import 'package:appfirst2025/ui/user/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/model/song.dart';
import '../now_playing/playing.dart';

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
      debugShowCheckedModeBanner: false,
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
    const DiscoveryTab(),
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
    return _SongItemSection(parent: this, song: songs[index]);
  }

  void observeData() {
    //Lay du lieu tu trong songStream
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }

  void showBottomSheet(){
    showModalBottomSheet(context: context, builder: (context){
      return ClipRRect(
        borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(16)),
        child: Container(
          height: 400,
          width: 400,
          color: Colors.grey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,// truc theo chieu doc
            mainAxisSize: MainAxisSize.min,//kich thuong nho nhat
            children: [
              const Text('Modal Bottom'),
              ElevatedButton(onPressed: ()=> Navigator.pop(context),
              child: const Text('Close Bottom'),)
            ],
          ),
        ),
      );
    });

  }

  void navigate(Song song){
    Navigator.push(context,
    CupertinoPageRoute(builder: (context){
      return NowPlaying(
        songs:songs,
        playingSong:song,
      );
    })
    );
  }
}

class _SongItemSection extends StatelessWidget {
  _SongItemSection({required this.parent, required this.song});

  final _HomeTabPageState parent;//tham chieu den parent widged, co the goi ham hoat cap nhat tu trang chinh
  final Song song;// doi tuong

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(//canh chinh noi dung
        left: 24,
        right: 8,
      ),
      leading: ClipRRect(//tao khung cho hinh anh
        borderRadius: BorderRadius.circular(9),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/images/logo.png',//hien thi hinh anh luc chua tai xong
          image: song.image,//lay hinh anh that
          width: 48,
          height: 48,
          imageErrorBuilder: (context, emrror, stackTrace) {// neu xay ra loi se su dung hinh anh local
            return Image.asset('assets/images/logo.png', width: 48, height: 48);
          },
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist), //ten tac gia
      trailing: IconButton(
        onPressed: () {
          parent.showBottomSheet();
        },
        icon: const Icon(Icons.more_horiz),
      ),
      onTap: (){
        parent.navigate(song);
      },
    );
  }
}
