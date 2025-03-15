import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  // ✅ 사용자 정보 저장
  Future<void> saveUserInfo(String team, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('teamName', team);
    await prefs.setString('userName', name);
    await prefs.setBool('isLoggedIn', true);
  }

  // ✅ 사용자 정보 불러오기
  Future<Map<String, String>> loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'teamName': prefs.getString('teamName') ?? "팀 없음",
      'userName': prefs.getString('userName') ?? "사용자 없음",
    };
  }

  // ✅ 점수 제출 내역 저장
  Future<void> saveSubmissions(List<Map<String, String>> submissions) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('submissions', jsonEncode(submissions));
  }

  // ✅ 점수 제출 내역 불러오기
  Future<List<Map<String, String>>> loadSubmissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? submissionsString = prefs.getString('submissions');

    if (submissionsString != null) {
      List<dynamic> rawData = jsonDecode(submissionsString);
      return rawData.map((e) => Map<String, String>.from(e)).toList();
    }
    return [];
  }

  // ✅ 모든 데이터 삭제 (로그아웃 시)
  Future<void> clearData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 저장된 모든 데이터 삭제
  }
}