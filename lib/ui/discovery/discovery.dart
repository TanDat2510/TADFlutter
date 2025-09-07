import 'package:appfirst2025/ui/home/viewmodel.dart';
import 'package:flutter/material.dart';
import '../../data/model/song.dart';
import 'discovery_search.dart';

class DiscoveryTab extends StatefulWidget {
  const DiscoveryTab({super.key});

  @override
  State<DiscoveryTab> createState() => _DiscoveryTabState();
}

class _DiscoveryTabState extends State<DiscoveryTab> {
  final TextEditingController _searchController = TextEditingController();
  final MusicViewModel _viewModel = MusicViewModel();

  List<Song> _allSongs = [];
  List<Song> _filteredSongs = [];

  @override
  void initState() {
    super.initState();
    _viewModel.loadSongs();
    _viewModel.songStream.stream.listen((songs) {
      setState(() {
        _allSongs = songs;
        _filteredSongs = songs;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.songStream.close();
    super.dispose();
  }

  Widget _buildBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        "assets/images/banner.png",
        fit: BoxFit.cover,
        height: 180,
        width: double.infinity,
      ),
    );
  }

  Widget _buildCategory(String title, String imagePath) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              imagePath,
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPlaylistItem(String title, String subtitle, String imagePath) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(imagePath, height: 50, width: 50, fit: BoxFit.cover),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DiscoverySearch(
                controller: _searchController,
                allSongs: _allSongs,
                filteredSongs: _filteredSongs,
                onResultsChanged: (results) {
                  setState(() {
                    _filteredSongs = results;
                  });
                },
              ),

              // Nếu không nhập gì thì hiển thị banner + danh mục + playlist
              if (_searchController.text.isEmpty) ...[
                _buildBanner(),
                const SizedBox(height: 20),

                const Text(
                  "Categories",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategory("Pop", "assets/images/pop.png"),
                      _buildCategory("Rock", "assets/images/rock.png"),
                      _buildCategory("HipHop", "assets/images/hiphop.png"),
                      _buildCategory("Jazz", "assets/images/jazz.png"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Recommended for you",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    _buildPlaylistItem("Top Hits 2025", "Artist Mix",
                        "assets/images/playlist1.png"),
                    _buildPlaylistItem("Relax & Chill", "Lo-fi Beats",
                        "assets/images/playlist2.png"),
                    _buildPlaylistItem("Workout Vibes", "Energy Mix",
                        "assets/images/playlist3.png"),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
