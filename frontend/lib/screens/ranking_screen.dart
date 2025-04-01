import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<Map<String, dynamic>> rankings = [];

  @override
  void initState() {
    super.initState();
    _fetchRankings();
  }

  Future<void> _fetchRankings() async {
    final prefs = await SharedPreferences.getInstance();
    final teamName = prefs.getString('teamName') ?? '';
    final userName = prefs.getString('userName') ?? '';

    final url = Uri.parse('http://localhost:8080/api/rankings');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'teamName': teamName,
        'userName': userName,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        rankings = data.map((e) => {
          'teamName': e['teamName'],
          'totalScore': e['totalScore'],
        }).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('랭킹 정보를 불러오지 못했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('팀 랭킹')),
      body: ListView.builder(
        itemCount: rankings.length,
        itemBuilder: (context, index) {
          final team = rankings[index];
          return ListTile(
            leading: Text('#${index + 1}'),
            title: Text(team['teamName']),
            trailing: Text('총점: ${team['totalScore']}'),
          );
        },
      ),
    );
  }
}