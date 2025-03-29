import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _sectorController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();

  List<Map<String, dynamic>> scoreList = [];

  void _submitScore() {
    final sector = _sectorController.text.trim();
    final score = _scoreController.text.trim();

    if (sector.isEmpty || score.isEmpty) return;

    setState(() {
      scoreList.add({
        'sector': sector,
        'score': score,
      });
    });

    _sectorController.clear();
    _scoreController.clear();
  }

  void _deleteScore(int index) {
    setState(() {
      scoreList.removeAt(index);
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
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
                    // TODO: 팀 랭킹 화면으로 이동
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