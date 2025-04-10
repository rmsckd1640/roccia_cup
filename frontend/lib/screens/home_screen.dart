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
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _enduranceController = TextEditingController();



  List<Map<String, dynamic>> scoreList = [];
  String? _role;

  int? _selectedSector;
  String? _scoreErrorText;
  String? _enduranceErrorText;
  bool _alreadySubmitted = false;
  String? _teamName;
  String? _userName;

  int _calculateTotalScore() {
    return scoreList
        .where((item) => item['sector'] != '99') // 지구력 제외
        .fold(0, (sum, item) => sum + int.parse(item['score']));
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _fetchUserScores();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role') ?? 'MEMBER';
      _teamName = prefs.getString('teamName');
      _userName = prefs.getString('userName');
    });
  }


  Future<void> _fetchUserScores() async {
    final prefs = await SharedPreferences.getInstance();
    final teamName = prefs.getString('teamName');
    final userName = prefs.getString('userName');

    if (teamName == null || userName == null) return;

    final url = Uri.parse('http://localhost:8080/api/scores/user?teamName=$teamName&userName=$userName');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        scoreList = data
            .map((item) => {
          'sector': item['sector'].toString(),
          'score': item['score'].toString(),
        })
            .toList();
      });
    }
  }

  void _submitScore() async {
    final score = _scoreController.text.trim();

    setState(() {
      _scoreErrorText = score.isEmpty ? '점수를 입력해주세요' : null;
      _alreadySubmitted = scoreList.any((item) => item['sector'] == _selectedSector.toString());
    });

    if (_selectedSector == null || score.isEmpty || _alreadySubmitted) return;

    final prefs = await SharedPreferences.getInstance();
    final teamName = prefs.getString('teamName');
    final userName = prefs.getString('userName');

    if (teamName == null || userName == null) return;

    final url = Uri.parse('http://localhost:8080/api/scores/submit');
    final body = {
      'teamName': teamName,
      'userName': userName,
      'sector': _selectedSector,
      'score': int.parse(score),
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      await _fetchUserScores();
      _scoreController.clear();
      setState(() {
        _selectedSector = null;
        _alreadySubmitted = false;
      });
    }
  }

  void _submitEnduranceScore() async {
    final enduranceScore = _enduranceController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    final teamName = prefs.getString('teamName');
    final userName = prefs.getString('userName');

    if (teamName == null || userName == null) return;

    final alreadyExists = scoreList.any((item) => item['sector'] == '99');

    setState(() {
      _enduranceErrorText = enduranceScore.isEmpty
          ? '지구력 점수를 입력해주세요'
          : (alreadyExists ? '중복 제출 불가!' : null);
    });

    if (enduranceScore.isEmpty || alreadyExists) return;

    final submitUrl = Uri.parse('http://localhost:8080/api/scores/submit');
    final response = await http.post(
      submitUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'teamName': teamName,
        'userName': userName,
        'sector': 99,
        'score': int.parse(enduranceScore),
      }),
    );

    if (response.statusCode == 200) {
      await _fetchUserScores();
      _enduranceController.clear();
      setState(() {
        _enduranceErrorText = null;
      });
    } else {
      // 서버에서 받은 메시지 보여주기
      final responseBody = jsonDecode(response.body);
      final errorMessage = responseBody is String
          ? responseBody
          : '중복 제출 불가!';

      setState(() {
        _enduranceErrorText = errorMessage;
      });
    }
  }


  void _deleteScore(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final teamName = prefs.getString('teamName');
    final userName = prefs.getString('userName');
    final sector = scoreList[index]['sector'];

    if (teamName == null || userName == null) return;

    final url = Uri.parse('http://localhost:8080/api/scores/delete/$teamName/$userName/$sector');
    final response = await http.delete(url);

    if (response.statusCode == 204) {
      setState(() {
        scoreList.removeAt(index);
      });
    }
  }

  void _showEditDialog() {
    final TextEditingController newTeamController = TextEditingController();
    final TextEditingController newNameController = TextEditingController();
    String? teamNameError;
    String? userNameError;
    String selectedRole = _role ?? 'MEMBER'; // 현재 역할 기본값

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('정보 수정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: newTeamController,
                    decoration: InputDecoration(
                      labelText: '새 팀명',
                      errorText: teamNameError,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: newNameController,
                    decoration: InputDecoration(
                      labelText: '새 이름',
                      errorText: userNameError,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(value: 'LEADER', child: Text('팀장')),
                      DropdownMenuItem(value: 'MEMBER', child: Text('팀원')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedRole = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: '역할 선택'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () async {
                    final newTeam = newTeamController.text.trim();
                    final newName = newNameController.text.trim();

                    setState(() {
                      teamNameError = newTeam.isEmpty ? '팀명을 입력해주세요' : null;
                      userNameError = newName.isEmpty ? '이름을 입력해주세요' : null;
                    });

                    if (newTeam.isEmpty || newName.isEmpty) return;

                    final url = Uri.parse('http://localhost:8080/api/users/update');
                    final body = {
                      'teamName': _teamName,
                      'userName': _userName,
                      'newTeamName': newTeam,
                      'newUserName': newName,
                      'newRole': selectedRole,
                    };

                    final response = await http.patch(
                      url,
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode(body),
                    );

                    if (response.statusCode == 200) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('teamName', newTeam);
                      await prefs.setString('userName', newName);
                      await prefs.setString('role', selectedRole); // 역할 저장

                      Navigator.of(context).pop();

                      setState(() {
                        _teamName = newTeam;
                        _userName = newName;
                        _role = selectedRole;
                      });

                      _fetchUserScores();
                    }
                  },
                  child: const Text('저장', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Score',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xCB9850F3),
        elevation: 4,
      ),

        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상단 유저 정보 박스
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE7F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('팀명: $_teamName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('이름: $_userName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('역할: ${_role == 'LEADER' ? '팀장' : '팀원'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('개인 총점: ${_calculateTotalScore()}점', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    // 섹터 + 점수 입력
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedSector,
                            items: List.generate(6, (i) => i + 1).map((num) {
                              return DropdownMenuItem(
                                value: num,
                                child: Text('섹터 $num'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSector = value;
                                _alreadySubmitted = false;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: '섹터 번호',
                              errorText: _alreadySubmitted ? '중복 제출 불가!' : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _scoreController,
                            decoration: InputDecoration(
                              labelText: '점수',
                              errorText: _scoreErrorText,
                            ),
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

                    if (_role == 'LEADER') ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _enduranceController,
                              decoration: InputDecoration(
                                labelText: '지구력 점수',
                                errorText: _enduranceErrorText,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _submitEnduranceScore,
                            child: const Text('제출'),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),
                    Text('제출 목록', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: scoreList.length,
                      itemBuilder: (context, index) {
                        final item = scoreList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              item['sector'] == '99'
                                  ? '지구력 - 점수: ${item['score']}'
                                  : '섹터 ${item['sector']} - 점수: ${item['score']}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteScore(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ✅ 고정된 하단 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _showEditDialog,
                    child: const Text('정보 수정'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RankingScreen()),
                      );
                    },
                    child: const Text('실시간 팀 랭킹'),
                  ),
                ],
              ),
            ),
          ],
        )



    );
  }
}
