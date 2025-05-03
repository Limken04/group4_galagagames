import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/score_model.dart';

class ScoreService {
  static const String SCORES_KEY = 'high_scores';

  Future<List<ScoreData>> fetchHighScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? scoresJson = prefs.getString(SCORES_KEY);
      
      if (scoresJson == null) return [];
      
      final List<dynamic> scores = json.decode(scoresJson);
      return scores
          .map((score) => ScoreData(score['score'] as int, score['date'] as String))
          .toList()
          ..sort((a, b) => b.score.compareTo(a.score));
    } catch (e) {
      print('Error fetching scores: $e');
      return [];
    }
  }

  Future<bool> submitScore(ScoreData newScore) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? scoresJson = prefs.getString(SCORES_KEY);
      final List<ScoreData> scores = [];
      
      if (scoresJson != null) {
        final List<dynamic> existingScores = json.decode(scoresJson);
        scores.addAll(
          existingScores.map((score) => ScoreData(score['score'] as int, score['date'] as String))
        );
      }
      
      scores.add(newScore);
      scores.sort((a, b) => b.score.compareTo(a.score));
      
      // Keep only top 10 scores
      final topScores = scores.take(10).toList();
      
      await prefs.setString(SCORES_KEY, json.encode(
        topScores.map((score) => {
          'score': score.score,
          'date': score.date,
        }).toList(),
      ));
      
      return true;
    } catch (e) {
      print('Error submitting score: $e');
      return false;
    }
  }
}
