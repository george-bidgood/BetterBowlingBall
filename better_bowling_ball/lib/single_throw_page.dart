import 'package:flutter/material.dart';
import 'package:better_bowling_ball/globals.dart';

class SingleThrowPage extends StatefulWidget {
  const SingleThrowPage({Key? key}) : super(key: key);

  @override
  _SingleThrowPageState createState() => _SingleThrowPageState();
}

class _SingleThrowPageState extends State<SingleThrowPage> {
  final double labelSize = 20;

  List<bool> selectedPins = <bool>[];
  double _currentSliderValue = 50;
  bool midThrow = false;

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

  clearPins() {
    for (var i = 0; i < 10; i++) {
      selectedPins[i] = false;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Single Throw")),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "Select Pins:",
                style: TextStyle(fontSize: labelSize),
              ),
              const SizedBox(
                height: 20,
              ),
              pinInterface(),
              const SizedBox(
                height: 20,
              ),
              Text("Slide Foot Position:",
                  style: TextStyle(fontSize: labelSize)),
              // const Image(image: AssetImage('lane_image.jpg')),
              const SizedBox(
                height: 20,
              ),
              Center(
                  child: Container(
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                color: Colors.brown.shade400,
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
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Spacer(),
                  Text("RPM:", style: TextStyle(fontSize: labelSize)),
                  const Spacer(),
                  Text("Speed:", style: TextStyle(fontSize: labelSize)),
                  const Spacer(),
                ],
              ),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                MaterialButton(
                  onPressed: () {
                    if (midThrow) {
                      setState(() {
                        clearPins();
                        _currentSliderValue = 50;
                      });
                    }

                    setState(() {
                      midThrow = !midThrow;
                    });
                  },
                  child: midThrow
                      ? const Text("End Throw")
                      : const Text("Begin Throw"),
                  color: midThrow ? Colors.red : Colors.green,
                )
              ])
            ]),
          ),
        ));
  }
}
