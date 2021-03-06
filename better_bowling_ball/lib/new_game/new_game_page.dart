import 'package:better_bowling_ball/db/bowling_database.dart';
import 'package:better_bowling_ball/model/model.game.dart';
import 'package:better_bowling_ball/new_game/game_throw.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewGamePage extends StatefulWidget {
  const NewGamePage({Key? key}) : super(key: key);

  @override
  _NewGamePageState createState() => _NewGamePageState();
}

class _NewGamePageState extends State<NewGamePage> {
  createGame() async {
    var game = await BowlingDatabase.instance.createGame(
        Game(name: nameTextField.text, notes: notesTextField.text, date: date));
    nameTextField.clear();
    notesTextField.clear();

    if (game.id != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => GameThrow(game: game)));
    } else {}
  }

  TextEditingController nameTextField = TextEditingController();
  TextEditingController notesTextField = TextEditingController();
  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Game")),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
          child: Column(children: [
            TextField(
                controller: nameTextField,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Game Title')),
            const Spacer(),
            TextField(
                controller: notesTextField,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Notes')),
            const Spacer(),
            Text((DateFormat('dd/MM/yyyy, h:mm a').format(date)),
                style: const TextStyle(fontSize: 20)),
            const Spacer(),
            Center(
                child: ElevatedButton(
                    onPressed: createGame, child: const Text("Create Game"))),
            const Spacer(flex: 13),
          ], crossAxisAlignment: CrossAxisAlignment.start)),
    );
  }
}
