import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:better_bowling_ball/globals.dart';

class BtPage extends StatefulWidget {
  FlutterBlue flutterBlue = GlobalData.flutterBlue;
  BtPage({Key? key}) : super(key: key);
  Guid ballService = Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
  final String title = "Bluetooth";

  final List<BluetoothDevice> devicesList = [];
  Map<Guid, List<int>> readValues = {};

  @override
  _BtPageState createState() => _BtPageState();
}

class _BtPageState extends State<BtPage> {
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];

  _addDeviceToList(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device) && mounted) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceToList(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceToList(result.device);
      }
    });
    widget.flutterBlue.isScanning.listen((bool isScanningBool) {
      if (mounted && !isScanningBool) {
        widget.flutterBlue.startScan(withServices: [widget.ballService]);
      }
    });
  }

  ListView _buildListViewOfDevices() {
    List<Container> containers = [];
    for (BluetoothDevice device in widget.devicesList) {
      containers.add(Container(
          height: 50,
          child: Row(children: [
            Expanded(
                child: Column(children: [
              Text(device.name == '' ? '(unknown device)' : device.name),
              Text(device.id.toString())
            ])),
            TextButton(
                child:
                    const Text('Connect', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  _connectDevice(device);
                })
          ])));
    }
    return ListView(
        padding: const EdgeInsets.all(8), children: <Widget>[...containers]);
  }

  Future<void> _connectDevice(BluetoothDevice device) async {
    widget.flutterBlue.stopScan();
    try {
      await device.connect(autoConnect: false);
    } catch (e) {
      if (e.toString() != "already_connected") {
        rethrow;
      }
    } finally {
      List<BluetoothService> servicesHolder = await device.discoverServices();
      setState(() {
        _services = servicesHolder;
        _connectedDevice = device;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildView());

  ListView _buildView() {
    if (_connectedDevice != null) {
      return _buildConnectedDeviceView();
    }
    return _buildListViewOfDevices();
  }

  ListView _buildConnectedDeviceView() {
    List<Container> containers = [];

    for (BluetoothService service in _services) {
      List<Widget> characteristicsWidget = [];
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        characteristic.value.listen((value) {
          print(value);
        });
        characteristicsWidget.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(characteristic.uuid.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    ..._buildReadWriteNotifyButton(characteristic),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('Value: ' +
                        widget.readValues[characteristic.uuid].toString()),
                  ],
                ),
                Divider(),
              ],
            ),
          ),
        );
      }
      containers.add(
        Container(
          child: ExpansionTile(
              title: Text(service.uuid.toString()),
              children: characteristicsWidget),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  List<ButtonTheme> _buildReadWriteNotifyButton(
      BluetoothCharacteristic characteristic) {
    List<ButtonTheme> buttons = [];

    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              child: Text('READ', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                var sub = characteristic.value.listen((value) {
                  setState(() {
                    widget.readValues[characteristic.uuid] = value;
                  });
                });
                await characteristic.read();
                sub.cancel();
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      GlobalData.writeCharacteristic = characteristic;
      GlobalData.accessible = true;
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              child: Text('WRITE', style: TextStyle(color: Colors.white)),
              onPressed: () {
                characteristic.write([0], withoutResponse: true);
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              child: Text('NOTIFY', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                characteristic.value.listen((value) {
                  GlobalData.dataValues.add(value);
                  print(value);
                });
                await characteristic.setNotifyValue(true);
              },
            ),
          ),
        ),
      );
    }

    return buttons;
  }
}
