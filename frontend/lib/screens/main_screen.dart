import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/submission.dart';
import '../widgets/custom_button.dart';
import '../widgets/score_list.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String teamName = "팀 없음";
  String userName = "사용자 없음";
  String? selectedSector;
  final TextEditingController _problemNumberController = TextEditingController();
  List<Submission> submissions = [];
  final StorageService storage = StorageService();
  final List<String> sectorOptions = List.generate(10, (index) => (index + 1).toString());

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSubmissions();
  }

  Future<void> _loadUserData() async {
    var userInfo = await storage.loadUserInfo();
    setState(() {
      teamName = userInfo['teamName'] ?? "팀 없음";
      userName = userInfo['userName'] ?? "사용자 없음";
    });
  }

  Future<void> _loadSubmissions() async {
    List<Map<String, dynamic>> loadedData = await storage.loadSubmissions();
    setState(() {
      submissions = loadedData.map((e) => Submission.fromJson(e)).toList();
    });
  }

  void _submitScore() {
    if (selectedSector == null || _problemNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("섹터와 문제 번호를 입력하세요!")),
      );
      return;
    }

    Submission newSubmission = Submission(
      sector: selectedSector!,
      problem: _problemNumberController.text,
    );

    setState(() {
      submissions.add(newSubmission);
    });

    storage.saveSubmissions(submissions.map((e) => e.toJson()).toList());

    _problemNumberController.clear();
    setState(() {
      selectedSector = null;
    });
  }

  Future<void> _logout() async {
    await storage.clearData();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("클라이밍 대회 점수 입력"),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("팀명: $teamName", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("이름: $userName", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),

            // 섹터 선택 드롭다운
            DropdownButtonFormField<String>(
              value: selectedSector,
              decoration: InputDecoration(labelText: "섹터 선택", border: OutlineInputBorder()),
              items: sectorOptions.map((String sector) {
                return DropdownMenuItem<String>(value: sector, child: Text("섹터 $sector"));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSector = newValue;
                });
              },
            ),

            SizedBox(height: 20),

            // 문제 번호 입력 필드
            TextField(
              controller: _problemNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "문제 번호 입력",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            // 점수 제출 버튼
            Center(
              child: CustomButton(text: "점수 제출", onPressed: _submitScore),
            ),

            SizedBox(height: 20),

            // 점수 리스트 (스크롤 가능)
            Expanded(child: ScoreList(submissions: submissions)),
          ],
        ),
      ),
    );
  }
}