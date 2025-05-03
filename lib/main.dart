import 'package:flutter/material.dart';

import 'models/score_model.dart';
import 'screens/galaga_game.dart';
import 'services/score_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galaga Game',
      theme: ThemeData.dark(), // Changed to dark theme
      debugShowCheckedModeBanner: false,
      // Define initial route and route mapping
      initialRoute: '/',
      routes: {'/': (context) => const MyHomePage(title: 'Galaga'), '/game': (context) => const GalagaGame()},
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  bool _visible = false;
  double _titleScale = 0.5;
  late AnimationController _menuController;
  late Animation<double> _menuScaleAnimation;
  late Animation<Offset> _slideAnimation;
  final ScoreService _scoreService = ScoreService();
  List<ScoreData> highScores = [];
  bool isLoading = false;

  Future<void> _fetchHighScores() async {
    setState(() => isLoading = true);
    try {
      final scores = await _scoreService.fetchHighScores();
      setState(() {
        highScores = scores;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching scores: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _menuScaleAnimation = CurvedAnimation(parent: _menuController, curve: Curves.elasticOut).drive(Tween<double>(begin: _titleScale, end: 1.0));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _menuController, curve: Curves.easeOutCubic));

    // Start animations and fetch scores
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _visible = true;
        _titleScale = 1.0;
      });
      _menuController.forward();
      _fetchHighScores();
    });
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black, title: Text(widget.title), centerTitle: true),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Game title
            ScaleTransition(
              scale: _menuScaleAnimation,
              child: const Text('GALAGA', style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 8)),
            ),

            // High Scores section with loading state
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _menuScaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.withOpacity(_visible ? 0.5 : 0.0)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 200,
                  width: 300,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('High Scores', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          if (isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child:
                            isLoading
                                ? const Center(child: Text('Loading scores...', style: TextStyle(color: Colors.white70)))
                                : ListView.builder(
                                  itemCount: highScores.length,
                                  itemBuilder: (context, index) {
                                    final score = highScores[index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(color: index.isEven ? Colors.blue.withOpacity(0.1) : Colors.transparent),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('#${index + 1}', style: const TextStyle(color: Colors.white70)),
                                          Text('${score.score}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          Text(score.date, style: const TextStyle(color: Colors.white70)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Animated Start Game button with scale and slide
            SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _menuScaleAnimation,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GalagaGame(onGameEnd: () => _fetchHighScores()))),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                    child: const Text('START GAME', style: TextStyle(fontSize: 24, letterSpacing: 2, color: Colors.white)),
                  ),
                ),
              ),
            ),

            // Animated Game Instructions with slide effect
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _menuScaleAnimation,
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(20),
                  child: const Column(
                    children: [
                      Text('How to Play:', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text(
                        '• Swipe left/right to move\n• Tap screen to shoot\n• Destroy enemies to score',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
