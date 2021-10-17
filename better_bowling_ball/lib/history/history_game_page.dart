import 'package:better_bowling_ball/db/bowling_database.dart';
import 'package:better_bowling_ball/model/model.game.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryGamePage extends StatefulWidget {
  final Game game;

  const HistoryGamePage({Key? key, required this.game}) : super(key: key);

  @override
  _HistoryGamePageState createState() => _HistoryGamePageState();
}

class _HistoryGamePageState extends State<HistoryGamePage> {
  void deleteGame() async {
    BowlingDatabase.instance.deleteGame(widget.game.id!).whenComplete(() {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("History Game")),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
          child: Column(
            children: [
              Text(widget.game.name, style: const TextStyle(fontSize: 20)),
              const Spacer(),
              Text(widget.game.notes, style: const TextStyle(fontSize: 20)),
              const Spacer(),
              Text((DateFormat('dd/MM/yyyy, h:mm a').format(widget.game.date)),
                  style: const TextStyle(fontSize: 20)),
              const Spacer(),
              Center(
                  child: ElevatedButton(
                      onPressed: deleteGame, child: const Text('Delete Game'))),
              const Spacer(flex: 30),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ));
  }
}
