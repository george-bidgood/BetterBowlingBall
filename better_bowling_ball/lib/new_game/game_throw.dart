import 'dart:developer';

import 'package:better_bowling_ball/DataProcessing/bowl_processing.dart';
import 'package:better_bowling_ball/model/model.bowl.dart';
import 'package:better_bowling_ball/db/bowling_database.dart';
import 'package:flutter/material.dart';
import 'package:better_bowling_ball/new_game/game_over.dart';
import 'package:better_bowling_ball/model/model.game.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:better_bowling_ball/globals.dart';

class GameThrow extends StatefulWidget {
  final Game game;

  const GameThrow({Key? key, required this.game}) : super(key: key);

  @override
  _GameThrowState createState() => _GameThrowState();
}

class _GameThrowState extends State<GameThrow> {
  final double labelSize = 20;

  // Data
  List<int> shotScores = <int>[];
  int currentShot = 0;
  bool dataRecieved = false;
  String rpm = "...";
  String speed = "...";

  // UI
  List<bool> selectedPins = <bool>[];
  double _currentSliderValue = 50;
  bool midThrow = false;

  // Returns the alertDialog
  AlertDialog alertDialog() {
    return AlertDialog(
      title: const Text('Waiting for BT data...'),
      content: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        dataRecieved
            ? const SizedBox(height: 0)
            : const CircularProgressIndicator(),
        Text('RPM: $rpm \nSpeed: $speed')
      ]),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            setState(() {
              dataRecieved = false;
              rpm = "...";
              speed = "...";
            });
            Navigator.of(context).pop(true);
          },
          child:
              dataRecieved ? const Text('Continue') : const SizedBox(height: 0),
        ),
      ],
    );
  }

  // save the shot into the database
  saveShot(bool empty) async {
    String footPlacement = _currentSliderValue.toString();
    int pinHit = empty ? -1 : selectedPins.where((item) => item).length;
    DateTime now = DateTime.now();

    await BowlingDatabase.instance.createBowl(Bowl(
        gamedID: widget.game.id,
        speed: 0.0,
        rpm: 0.0,
        xRotation: 0.0,
        yRotation: 0.0,
        zRotation: 0.0,
        footPlacement: footPlacement,
        pinHit: pinHit,
        timestamp: now));
    return;
  }

  // Move to end game screen
  endGame() {
    for (var i = currentShot; i < 21; i++) {
      saveShot(false);
    }

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => GameOver(game: widget.game)));
  }

  // resetUI
  resetUI() {
    setState(() {
      _currentSliderValue = 50;
      clearPins();
    });
  }

  buttonPressed() {
    bool secondShot = false;
    if (currentShot % 2 == 1) {
      secondShot = true;
    }

    List<List<int>> dataValues = [];

    if (!midThrow) {
      Future.delayed(const Duration(seconds: 5)).then((value) {
        log("dataRecieved");
        setState(() {
          dataRecieved = true;
          rpm = "100";
          speed = "30";
        });
        Navigator.of(context, rootNavigator: true).pop('dialog');
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => alertDialog());
      });

      // GlobalData.dataFetcher().then((value) {
      //   dataValues = value;
      //   Processing.processData3(value, widget.game.id!);

      //   setState(() {
      //     dataRecieved = true;
      //     rpm = "100";
      //     speed = "30";
      //   });
      Navigator.of(context, rootNavigator: true).pop('dialog');
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => alertDialog());

      //   log(value.toString());
      // });
    }

    if (midThrow) {
      int throwScore = selectedPins.where((item) => item).length;

      // 10th frame
      if (currentShot > 17) {
        setState(() {
          saveShot(false);
          shotScores[currentShot] = throwScore;
          currentShot += 1;
          resetUI();
          midThrow = !midThrow;
        });

        if (currentShot == 20 && (shotScores[18] + shotScores[19] < 10)) {
          endGame();
        }

        if (currentShot == 21) {
          endGame();
        }

        return;
      }

      // Not a strike
      if (throwScore < 10) {
        setState(() {
          saveShot(false);
          shotScores[currentShot] = throwScore;
          currentShot += 1;
        });
      }

      // Strike
      if (throwScore == 10) {
        setState(() {
          saveShot(false);
          if (secondShot) {
            shotScores[currentShot] = throwScore;
            currentShot += 1;
          } else {
            saveShot(true);
            shotScores[currentShot] = throwScore;
            currentShot += 2;
          }
        });
      }

      // reset UI
      resetUI();

      // wait for bt data:
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => alertDialog());
    }

    setState(() {
      midThrow = !midThrow;
    });
  }

  // Clears the list of knocked pins
  clearPins() {
    for (var i = 0; i < 10; i++) {
      selectedPins[i] = false;
    }
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

  // Single pin for the pinInterface
  Widget pinButton(int index) {
    return MaterialButton(
      onPressed: () {
        if (midThrow) {
          setState(() {
            selectedPins[index] = !selectedPins[index];
          });
        }
      },
      color: selectedPins[index] ? Colors.green : Colors.grey,
      shape: const CircleBorder(),
    );
  }

  // Interface for marking which pins were knocked down
  Widget pinInterface() {
    for (var i = 0; i < 10; i++) {
      selectedPins.add(false);
    }

    return Column(
      children: [
        Row(
          children: [pinButton(6), pinButton(7), pinButton(8), pinButton(9)],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        Row(
          children: [pinButton(3), pinButton(4), pinButton(5)],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        Row(
          children: [
            pinButton(1),
            pinButton(2),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        Row(
          children: [pinButton(0)],
          mainAxisAlignment: MainAxisAlignment.center,
        )
      ],
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure you want to end game?'),
            content: const Text(
                'Ending the game early will set your remaining shots to 0'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  endGame();
                },
                child: const Text('Exit'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            appBar: AppBar(title: Text(widget.game.name)),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      scoreInterface(),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Select Pins:",
                        style: TextStyle(fontSize: labelSize),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      pinInterface(),
                      const SizedBox(
                        height: 10,
                      ),
                      Text("Slide Foot Position:",
                          style: TextStyle(fontSize: labelSize)),
                      // const Image(image: AssetImage('lane_image.jpg')),
                      const SizedBox(
                        height: 10,
                      ),
                      const Center(
                          child: Image(
                        image: AssetImage('./assets/lane_image.jpg'),
                        height: 110,
                      )),

                      Slider(
                        value: _currentSliderValue,
                        min: 0,
                        max: 100,
                        divisions: 50,
                        onChanged: (double value) {
                          if (midThrow) {
                            setState(() {
                              _currentSliderValue = value;
                            });
                          }
                        },
                      ),
                      const Spacer(),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            MaterialButton(
                              onPressed: buttonPressed,
                              child: midThrow
                                  ? const Text("End Throw")
                                  : const Text("Begin Throw"),
                              color: midThrow ? Colors.red : Colors.green,
                            )
                          ])
                    ]),
              ),
            )));
  }
}
