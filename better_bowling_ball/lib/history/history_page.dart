import 'dart:developer';

import 'package:better_bowling_ball/db/bowling_database.dart';
import 'package:better_bowling_ball/history/history_game_page.dart';
import 'package:better_bowling_ball/model/model.game.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // list of games to populate ListView
  var games = <Game>[];

  // Populate list of games with DB data
  loadGames() async {
    games = await BowlingDatabase.instance.readAllGames();
    setState(() {});
  }

  // Create a ListTile widget given a Game object
  ListTile gameTile(Game game) {
    return ListTile(
      onTap: () {
        Navigator.of(context)
            .push(
              new MaterialPageRoute(
                  builder: (_) => new HistoryGamePage(game: game)),
            )
            .then((val) => val ? loadGames() : null);
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => HistoryGamePage(game: game)));
      },
      title: Text(game.name),
      subtitle: Text((DateFormat('MM/dd/yyyy, h:mm a').format(game.date))),
      trailing: const Icon(Icons.arrow_right),
    );
  }

  @override
  void initState() {
    super.initState();
    loadGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("History"), actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  loadGames();
                },
                child: const Icon(
                  Icons.refresh,
                  size: 26.0,
                ),
              ))
        ]),
        body: ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              return Card(child: gameTile(games[index]));
            }));
  }
}
