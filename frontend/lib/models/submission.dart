class Submission {
  final String sector;
  final String problem;

  Submission({required this.sector, required this.problem});

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      sector: json['sector'],
      problem: json['problem'],
    );
  }

  Map<String, String> toJson() {
    return {'sector': sector, 'problem': problem};
  }
}