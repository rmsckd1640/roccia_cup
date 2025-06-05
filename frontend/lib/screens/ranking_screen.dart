import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';



class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

// ✅ 등수 기준 메달 이모지/스타일
String? _getMedalEmojiByRank(int rank) {
  switch (rank) {
    case 1:
      return '1등';
    case 2:
      return '2등';
    case 3:
      return '3등';
    default:
      return null;
  }
}

Color? _getMedalBackgroundColorByRank(int rank) {
  switch (rank) {
    case 1:
      return const Color(0xFFFFF8DC); // 연한 금색
    case 2:
      return const Color(0xFFF5F5F5); // 연한 은색
    case 3:
      return const Color(0xFFFBE4D2); // 연한 동색
    default:
      return Colors.white;
  }
}

Color? _getMedalBorderColorByRank(int rank) {
  switch (rank) {
    case 1:
      return const Color(0xFFFFD700); // 금 테두리
    case 2:
      return const Color(0xFFC0C0C0); // 은 테두리
    case 3:
      return const Color(0xFFCD7F32); // 동 테두리
    default:
      return Colors.transparent;
  }
}

class _RankingScreenState extends State<RankingScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> rankings = [];
  Map<String, dynamic>? _myTeamData;
  String? _myTeamName;

  @override
  void initState() {
    super.initState();
    _fetchRankings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchRankings() async {
    final prefs = await SharedPreferences.getInstance();
    final teamName = prefs.getString('teamName') ?? '';
    final userName = prefs.getString('userName') ?? '';
    _myTeamName = teamName;

    final url = Uri.parse('/api/rankings');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'teamName': teamName, 'userName': userName}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<Map<String, dynamic>> rawList = data.map((e) => {
        'teamName': e['teamName'],
        'averageScore': e['averageScore'],
      }).toList();

      setState(() {
        rankings = _applyRankingWithTies(rawList);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('랭킹 정보를 불러오지 못했습니다.')),
      );
    }
  }

  List<Map<String, dynamic>> _applyRankingWithTies(List<Map<String, dynamic>> rawList) {
    rawList.sort((a, b) =>
        (b['averageScore'].toDouble()).compareTo(a['averageScore'].toDouble()));



    int rank = 1;
    int count = 1;
    double? prevScore;
    for (var i = 0; i < rawList.length; i++) {
      double score = rawList[i]['averageScore'];
      if (prevScore != null && score == prevScore) {
        rawList[i]['rank'] = rank;
        count++;
      } else {
        rank = i + 1;
        rawList[i]['rank'] = rank;
        count = 1;
        prevScore = score;
      }
    }

    _myTeamData = rawList.firstWhere(
          (team) => team['teamName'] == _myTeamName,
      orElse: () => {'teamName': _myTeamName, 'averageScore': 0.0, 'rank': null},
    );



    return rawList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '실시간 팀 랭킹',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xCB9850F3),
        elevation: 4,
      ),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 6,
        radius: const Radius.circular(12),
        interactive: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_myTeamData != null)
                _buildTeamCard(_myTeamData!, highlight: true, label: '내 팀 등수'),
              if (_myTeamData != null)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    '전체 등수',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ...rankings.map((team) => _buildTeamCard(team)).toList(),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildTeamCard(Map<String, dynamic> team,
      {bool highlight = false, String? label}) {
    final teamName = team['teamName'];
    final averageScore = team['averageScore'];
    final rank = team['rank'];
    final isMyTeam = teamName == _myTeamName;

    final medalEmoji = _getMedalEmojiByRank(rank);
    final backgroundColor =
    highlight ? Colors.deepPurple[50] : _getMedalBackgroundColorByRank(rank);
    final borderColor = _getMedalBorderColorByRank(rank);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        Card(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor!, width: 2),
          ),
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: Text(
              '$rank등',
              style: TextStyle(
                fontSize: 18,
                fontWeight: isMyTeam ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            title: Text(
              teamName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMyTeam ? Colors.deepPurple : Colors.black,
              ),
            ),
            trailing: Text(
              '팀 평균 점수: ${averageScore.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isMyTeam ? Colors.deepPurple : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
