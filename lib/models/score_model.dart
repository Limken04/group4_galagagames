class ScoreData {
  final int score;
  final String date;

  ScoreData(this.score, this.date);

  factory ScoreData.fromJson(Map<String, dynamic> json) {
    return ScoreData(json['score'] as int, json['date'] as String);
  }

  Map<String, dynamic> toJson() => {'score': score, 'date': date};
}
