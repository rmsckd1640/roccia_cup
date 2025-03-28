import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _teamController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  void _login() async {
    final teamName = _teamController.text.trim();
    final userName = _nameController.text.trim();

    if (teamName.isEmpty || userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('팀명과 이름을 모두 입력해주세요')),
      );
      return;
    }

    final url = Uri.parse('http://localhost:8080/api/users/login'); // 여기 IP는 본인 IP로 변경!
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'teamName': teamName,
        'userName': userName,
      }),
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('teamName', teamName);
      await prefs.setString('userName', userName);
      // 필요하면 userId, createdAt 등도 저장 가능

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 실패. 서버를 확인해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _teamController,
              decoration: const InputDecoration(labelText: '팀명'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _login,
              child: const Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}