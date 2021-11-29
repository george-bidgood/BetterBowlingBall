import 'dart:developer';

import 'package:better_bowling_ball/db/bowling_database.dart';
import 'package:better_bowling_ball/model/model.bowl.dart';
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
  // list of games to populate ListView
  var bowls = <Bowl>[];
  List<int> shotScores = List.generate(21, (index) => -1);
  List<int> frameScores = List.generate(10, (index) => -1);

  // calculate the score of the game
  calculateScore() {
    return 300;
  }

  // Populate list of games with DB data
  loadBowls() async {
    bowls = await BowlingDatabase.instance.readBowls(widget.game.id!);
    for (var i = 0; i < bowls.length; i++) {
      shotScores[i] = (bowls[i].pinHit == -1) ? -1 : bowls[i].pinHit;
    }
    for (var i = 0; i < 10; i++) {
      frameScores[i] = shotScores[2 * i] + shotScores[2 * i + 1];
    }
    log("frameScores: ${shotScores.toString()}");
    setState(() {});
  }

  // Create a ListTile widget given a Game object
  ListTile bowlTile(int i) {
    var shot1 = bowls[2 * i];
    var shot2 = bowls[2 * i + 1];

    return ListTile(
        onTap: () {},
        title: Text("Frame ${i + 1}: ${frameScores[i]}"),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Shot 1: ${shot1.pinHit}"),
          Text("\t footPlacement: ${shot1.footPlacement}"),
          (() {
            if (shot2.pinHit != -1) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Shot 2: ${shot2.pinHit}"),
                  Text("\t footPlacement: ${shot2.footPlacement}"),
                ],
              );
            }
            return const SizedBox();
          }()),
        ]));
  }

  void deleteGame() async {
    BowlingDatabase.instance.deleteGame(widget.game.id!).whenComplete(() {
      Navigator.pop(context, true);
    });
  }

  // Cell for each shot
  Widget shotCell(int i) {
    return Container(
      child: Center(
          child: Text(
        (() {
          if (shotScores[i] == -1) {
            return "";
          }
          if (shotScores[i] < 10) {
            return shotScores[i].toString();
          }
          return "X";
        }()),
        style: const TextStyle(fontSize: 12),
      )),
      height: 18,
      width: 11,
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
    );
  }

  // Cell for each frame (turn)
  Widget frameCell(int i) {
    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
              child: Center(child: Text((i / 2 + 1).toInt().toString())),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black))),
          flex: 1,
        ),
        Expanded(
          child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  shotCell(i),
                  shotCell(i + 1),
                  (() {
                    if (i == 18) {
                      return shotCell(i + 2);
                    }
                    return const SizedBox();
                  }())
                ],
              ),
              height: 1,
              width: 1,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black))),
          flex: 2,
        ),
      ],
    ));
  }

  // Interface to keep track of the game score
  Widget scoreInterface() {
    for (var i = 0; i < 21; i++) {
      shotScores.add(-1);
    }

    return Container(
      color: Colors.grey.shade300,
      height: 60,
      child: Row(
        children: [for (var i = 0; i < 20; i += 2) frameCell(i)],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadBowls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.game.name),
          bottom: PreferredSize(
              child: Text(
                DateFormat('MM/dd/yyyy, h:mm a').format(widget.game.date),
                style: const TextStyle(color: Colors.white),
              ),
              preferredSize: Size.zero),
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                child: Column(
                  children: [
                    Text(
                      "Final Score: ${calculateScore()}",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    scoreInterface(),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                        child: ListView.builder(
                            itemCount: bowls.length ~/ 2,
                            itemBuilder: (context, index) {
                              return Card(child: bowlTile(index));
                            })),
                    Center(
                        child: ElevatedButton(
                            onPressed: deleteGame,
                            child: const Text('Delete Game'))),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                ))));
  }
}
