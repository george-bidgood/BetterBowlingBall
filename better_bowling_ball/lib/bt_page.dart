import 'package:flutter/material.dart';

class BtPage extends StatefulWidget {
  const BtPage({Key? key}) : super(key: key);

  @override
  _BtPageState createState() => _BtPageState();
}

class _BtPageState extends State<BtPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bluetooth")),
      body: const Center(child: Text('Bluetooth Page')),
    );
  }
}
