import 'package:appfirst2025/ui/now_playing/playing.dart';
import 'package:flutter/material.dart';
import '../../data/model/song.dart';

class DiscoverySearch extends StatelessWidget {
  final TextEditingController controller;
  final List<Song> allSongs;
  final List<Song> filteredSongs;
  final Function(List<Song>) onResultsChanged;

  const DiscoverySearch({
    super.key,
    required this.controller,
    required this.allSongs,
    required this.filteredSongs,
    required this.onResultsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Search songs, artists...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          ),
          onChanged: (query) {
            final results = allSongs
                .where((song) =>
            song.title.toLowerCase().contains(query.toLowerCase()) ||
                song.artist.toLowerCase().contains(query.toLowerCase()))
                .toList();
            onResultsChanged(results);
          },
        ),
        const SizedBox(height: 20),

        // Nếu có nhập và có kết quả thì show danh sách
        if (controller.text.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredSongs.length,
            itemBuilder: (context, index) {
              final song = filteredSongs[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    song.image,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) {
                      return Image.asset("assets/images/logo.png",
                          height: 50, width: 50);
                    },
                  ),
                ),
                title: Text(song.title),
                subtitle: Text(song.artist),

                // Khi click thì mở NowPlaying
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NowPlaying(
                        playingSong: song,
                        songs: allSongs,
                      ),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
