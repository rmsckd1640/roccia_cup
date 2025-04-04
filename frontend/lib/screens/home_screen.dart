import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';
import 'ranking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _sectorController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();

  List<Map<String, dynamic>> scoreList = [];

  @override
  void initState() {
    super.initState();
    _fetchUserScores();
  }

  Future<void> _fetchUserScores() async {
    final prefs = await SharedPreferences.getInstance();
    final teamName = prefs.getString('teamName');
    final userName = prefs.getString('userName');

    if (teamName == null || userName == null) return;

    final url = Uri.parse(
        'http://localhost:8080/api/scores/user?teamName=$teamName&userName=$userName');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        scoreList = data.map((item) => {
          'sector': item['sector'].toString(),
          'score': item['score'].toString(),
        }).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('점수 목록 불러오기 실패')),
      );
    }
  }

  void _submitScore() async {
    final sector = _sectorController.text.trim();
    final score = _scoreController.text.trim();

    if (sector.isEmpty || score.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final teamName = prefs.getString('teamName');
    final userName = prefs.getString('userName');

    if (teamName == null || userName == null) return;

    final url = Uri.parse('http://localhost:8080/api/scores/submit');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'teamName': teamName,
        'userName': userName,
        'sector': int.parse(sector),
        'score': int.parse(score),
      }),
    );

    if (response.statusCode == 200) {

      await _fetchUserScores();

      setState(() {
        scoreList.add({
          'sector': sector,
          'score': score,
        });
      });

      _sectorController.clear();
      _scoreController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('점수가 제출되었습니다!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제출 실패! 서버를 확인해주세요')),
      );
    }
  }

  void _deleteScore(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final teamName = prefs.getString('teamName');
    final userName = prefs.getString('userName');
    final sector = scoreList[index]['sector'];

    if (teamName == null || userName == null) return;

    final url = Uri.parse(
        'http://localhost:8080/api/scores/delete/$teamName/$userName/$sector');

    final response = await http.delete(url);

    if (response.statusCode == 204) {
      setState(() {
        scoreList.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('점수가 삭제되었습니다!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제 실패! 서버를 확인해주세요')),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final teamName = prefs.getString('teamName');
    final userName = prefs.getString('userName');

    if (teamName == null || userName == null) return;

    final url = Uri.parse('http://localhost:8080/api/users/logout/$teamName/$userName');
    final response = await http.delete(url);

    if (response.statusCode == 204) {
      await prefs.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃 실패! 서버를 확인해주세요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('점수 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sectorController,
                    decoration: const InputDecoration(labelText: '섹터 번호'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _scoreController,
                    decoration: const InputDecoration(labelText: '점수'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submitScore,
                  child: const Text('제출'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: scoreList.length,
                itemBuilder: (context, index) {
                  final item = scoreList[index];
                  return ListTile(
                    title: Text('섹터 ${item['sector']} - 점수: ${item['score']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteScore(index),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _logout,
                  child: const Text('로그아웃'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RankingScreen()),
                    );
                  },
                  child: const Text('팀 랭킹 보기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}