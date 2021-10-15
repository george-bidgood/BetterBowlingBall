import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BtPage extends StatefulWidget {
  BtPage({Key? key}) : super(key: key);

  final String title = "Bluetooth";
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = [];
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};

  @override
  _BtPageState createState() => _BtPageState();
}

class _BtPageState extends State<BtPage> {
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];

  _addDeviceToList(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
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
    widget.flutterBlue.startScan();
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
      await device.connect();
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
              onPressed: () {},
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              child: Text('WRITE', style: TextStyle(color: Colors.white)),
              onPressed: () {},
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
              onPressed: () {},
            ),
          ),
        ),
      );
    }

    return buttons;
  }
}
