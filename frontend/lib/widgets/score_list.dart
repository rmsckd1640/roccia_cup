import 'package:flutter/material.dart';
import '../models/submission.dart';

class ScoreList extends StatelessWidget {
  final List<Submission> submissions;

  const ScoreList({required this.submissions, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: submissions.isEmpty
          ? Center(child: Text("아직 제출된 기록이 없습니다."))
          : Scrollbar(
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: submissions.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text("섹터: ${submissions[index].sector}"),
              subtitle: Text("문제 번호: ${submissions[index].problem}"),
            );
          },
        ),
      ),
    );
  }
}