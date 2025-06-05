import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final team = prefs.getString('teamName');
    final name = prefs.getString('userName');

    if (team != null && name != null) {
      // 서버에 유저 존재 여부 확인
      final url = Uri.parse('https://roccia-cup.site/api/scores/user?teamName=$team&userName=$name');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return const HomeScreen();
      } else {
        await prefs.clear();
        return const LoginScreen();
      }
    } else {
      return const LoginScreen();
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roccia Cup',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Pretendard',
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}