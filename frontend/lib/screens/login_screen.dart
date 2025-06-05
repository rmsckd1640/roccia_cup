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

  String _selectedRole = 'MEMBER'; // 기본값: 팀원
  String? _errorText; // 에러 메시지 상태
  String? _teamErrorText;
  String? _nameErrorText;


  void _login() async {
    final teamName = _teamController.text.trim();
    final userName = _nameController.text.trim();

    setState(() {
      _teamErrorText = teamName.isEmpty ? '팀명을 입력해주세요' : null;
      _nameErrorText = userName.isEmpty ? '이름을 입력해주세요' : null;
    });

    if (teamName.isEmpty || userName.isEmpty) return;

    final url = Uri.parse('/api/users/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'teamName': teamName,
        'userName': userName,
        'role': _selectedRole,
      }),
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('teamName', teamName);
      await prefs.setString('userName', userName);
      await prefs.setString('role', _selectedRole);

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      setState(() {
        _errorText = '로그인 실패. 서버를 확인해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',

        ),
        backgroundColor: Color(0xCB9850F3),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _teamController,
              decoration: InputDecoration(
                labelText: '팀명',
                errorText: _teamErrorText,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '이름',
                errorText: _nameErrorText,
              ),
            ),



            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('팀원'),
                    value: 'MEMBER',
                    groupValue: _selectedRole,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('팀장'),
                    value: 'LEADER',
                    groupValue: _selectedRole,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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