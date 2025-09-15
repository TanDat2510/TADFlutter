import 'package:flutter/material.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _isDarkMode = false;
  String _language = "English";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Preferences
          const Text(
            "Preferences",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Dark Mode
          SwitchListTile(
            value: _isDarkMode,
            onChanged: (val) {
              setState(() {
                _isDarkMode = val;
              });
              // TODO: cập nhật theme toàn app
            },
            secondary: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
          ),

          // Language
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Language"),
            subtitle: Text(_language),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: const Text("Choose Language"),
                    children: [
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, "English"),
                        child: const Text("English"),
                      ),
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, "Vietnamese"),
                        child: const Text("Vietnamese"),
                      ),
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, "Spanish"),
                        child: const Text("Spanish"),
                      ),
                    ],
                  );
                },
              );

              if (result != null) {
                setState(() {
                  _language = result;
                });
              }
            },
          ),
          const Divider(height: 32),

          // Download
          const Text(
            "Download",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: true,
            onChanged: (val) {
              // TODO: bật/tắt tải nhạc chất lượng cao
            },
            secondary: const Icon(Icons.download),
            title: const Text("High quality download"),
          ),
          SwitchListTile(
            value: true,
            onChanged: (val) {
              // TODO: bật/tắt chỉ tải qua WiFi
            },
            secondary: const Icon(Icons.wifi),
            title: const Text("Download only on WiFi"),
          ),
          const Divider(height: 32),

          // Notifications
          const Text(
            "Notifications",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: true,
            onChanged: (val) {
              // TODO: bật/tắt thông báo nhạc mới
            },
            secondary: const Icon(Icons.music_note),
            title: const Text("New music alerts"),
          ),
          SwitchListTile(
            value: false,
            onChanged: (val) {
              // TODO: bật/tắt gợi ý playlist
            },
            secondary: const Icon(Icons.playlist_play),
            title: const Text("Playlist suggestions"),
          ),
          const Divider(height: 32),

          // About & Logout
          const Text(
            "About",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About App"),
            onTap: () {
              // TODO: Hiện dialog hoặc trang thông tin App
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // TODO: Xử lý logout
            },
          ),
        ],
      ),
    );
  }
}
