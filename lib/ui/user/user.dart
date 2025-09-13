import 'package:appfirst2025/services/auth_service.dart';
import 'package:appfirst2025/ui/user/register_page.dart';
import 'package:appfirst2025/ui/user/login_page.dart'; // thêm import LoginPage
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  final AuthService _authService = AuthService();

  Future<void> logout() async {
    await _authService.logout();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: _authService.userChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              final user = snapshot.data!;
              return Column(
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Colors.purple, Colors.blueAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 45,
                            backgroundImage:
                            AssetImage("assets/images/avatar.png"),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.email ?? "No Email",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "🎵 Music is life 🎶",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  Expanded(
                    child: ListView(
                      children: [
                        _buildMenuItem(Icons.library_music, "My Playlists"),
                        _buildMenuItem(Icons.favorite, "Favorites"),
                        _buildMenuItem(Icons.headphones, "Subscriptions"),
                        _buildMenuItem(Icons.settings, "Settings"),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: logout,
                      child: const Text(
                        "Log Out",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              );
            }

            // 👉 Nếu chưa đăng nhập → Chuyển sang trang LoginPage
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  "Go to Login Page",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.purple),
        title: Text(
          title,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            color: Colors.grey, size: 16),
        onTap: () {
          // TODO: xử lý khi bấm vào từng menu
        },
      ),
    );
  }
}
