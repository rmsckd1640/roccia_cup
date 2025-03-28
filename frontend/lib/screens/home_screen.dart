import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<String> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final team = prefs.getString('teamName') ?? '';
    final name = prefs.getString('userName') ?? '';
    return '$team - $name';
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 로그인 정보 삭제

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Roccia Cup')),
      body: Center(
        child: FutureBuilder<String>(
          future: _getUserName(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '환영합니다, ${snapshot.data}님!',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _logout(context),
                  child: const Text('로그아웃'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}