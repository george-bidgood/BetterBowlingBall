import 'package:better_bowling_ball/DataProcessing/bowl_processing.dart';
import 'package:better_bowling_ball/main.dart';
import 'package:flutter/material.dart';
import 'package:better_bowling_ball/model/model.game.dart';

class GameOver extends StatefulWidget {
  final Game game;

  const GameOver({Key? key, required this.game}) : super(key: key);

  @override
  _GameOverState createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> {
  int score = 0;

  calculateGameScore() {
    Processing.getScore(widget.game.id!).then((value) {
      setState(() {
        score = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    calculateGameScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Center(
            child: Text(
          "Game Over!",
          style: TextStyle(fontSize: 20),
        )),
        const SizedBox(height: 40),
        Center(child: Text("Final Score: $score")),
        const SizedBox(height: 40),
        Center(
            child: ElevatedButton(
                onPressed: () =>
                    {Navigator.of(context).popUntil((route) => route.isFirst)},
                child: const Text("Home")))
      ],
    ));
  }
}
