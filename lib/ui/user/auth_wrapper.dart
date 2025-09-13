import 'package:appfirst2025/ui/discovery/discovery.dart';
import 'package:appfirst2025/ui/home/home.dart';
import 'package:appfirst2025/ui/settings/settings.dart';
import 'package:appfirst2025/ui/user/user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appfirst2025/ui/user/login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const AccountTabWithNavigation();
        }
        return const LoginPage();
      },
    );
  }
}

// Tạo wrapper cho AccountTab với bottom navigation
class AccountTabWithNavigation extends StatefulWidget {
  const AccountTabWithNavigation({super.key});

  @override
  State<AccountTabWithNavigation> createState() => _AccountTabWithNavigationState();
}

class _AccountTabWithNavigationState extends State<AccountTabWithNavigation> {
  int _currentIndex = 2;

  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingsTab(),
  ];

  final List<String> _tabTitles = [
    'Home',
    'Discovery',
    'Account',
    'Settings'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[_currentIndex]),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Ẩn back button
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs, // Giữ state của các tab
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.album),
            label: 'Discovery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}