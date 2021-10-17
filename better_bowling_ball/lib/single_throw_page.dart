import 'package:flutter/material.dart';

class SingleThrowPage extends StatefulWidget {
  const SingleThrowPage({Key? key}) : super(key: key);

  @override
  _SingleThrowPageState createState() => _SingleThrowPageState();
}

class _SingleThrowPageState extends State<SingleThrowPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Single Throw")),
      body: const Center(child: Text('Single Throw Page')),
    );
  }
}
