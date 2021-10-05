import 'package:better_bowling_ball/bt_page.dart';
import 'package:better_bowling_ball/history_page.dart';
import 'package:better_bowling_ball/new_game_page.dart';
import 'package:better_bowling_ball/single_throw_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// This widget is the root of your application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better Bowlling Ball',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomePage(title: 'Welcome, <username>'),
      routes: {
        'newGame': (_) => const NewGamePage(),
        'singleThrow': (_) => const SingleThrowPage(),
        'history': (_) => const HistoryPage(),
        'bt': (_) => BtPage(),
      },
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SafeArea(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20, 0, 20, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              //mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(
                  flex: 8,
                ),
                const Center(
                    child: Text(
                  "Better Bowling Ball App",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )),
                const Spacer(
                  flex: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('bt');
                  },
                  child: const Text("Bluetooth"),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('newGame');
                  },
                  child: const Text("New Game"),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('singleThrow');
                  },
                  child: const Text("Single Throw"),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('history');
                  },
                  child: const Text("History"),
                ),
              ],
            ),
          ),
        ));
  }
}
