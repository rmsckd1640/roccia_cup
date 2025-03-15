import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _teamController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final StorageService storage = StorageService();

  Future<void> _login() async {
    String teamName = _teamController.text.trim();
    String userName = _nameController.text.trim();

    if (teamName.isEmpty || userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("팀명과 이름을 입력하세요!")),
      );
      return;
    }

    await storage.saveUserInfo(teamName, userName);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("로그인")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _teamController, decoration: InputDecoration(labelText: "팀명")),
            SizedBox(height: 16),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "이름")),
            SizedBox(height: 32),
            ElevatedButton(onPressed: _login, child: Text("로그인")),
          ],
        ),
      ),
    );
  }
}