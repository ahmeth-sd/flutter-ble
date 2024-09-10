// lib/connected_device_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bluetooth_helper.dart';
import 'write_command_page.dart';

class ConnectedDevicePage extends StatefulWidget {
  final BluetoothDevice device;
  final List<BluetoothService> services;

  ConnectedDevicePage({required this.device, required this.services});

  @override
  _ConnectedDevicePageState createState() => _ConnectedDevicePageState();
}

class _ConnectedDevicePageState extends State<ConnectedDevicePage> {
  final BluetoothHelper _bluetoothHelper = BluetoothHelper();
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};
  final TextEditingController _writeController = TextEditingController();

  List<Widget> _buildReadWriteNotifyButton(BluetoothCharacteristic characteristic) {
    List<Widget> buttons = <Widget>[];

    if (characteristic.properties.read) {
      buttons.add(
        TextButton(
          child: const Text('READ', style: TextStyle(color: Colors.blue)),
          onPressed: () async {
            var sub = characteristic.value.listen((value) {
              setState(() {
                readValues[characteristic.uuid] = value;
              });
            });
            await characteristic.read();
            sub.cancel();
          },
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        TextButton(
          child: const Text('WRITE', style: TextStyle(color: Colors.blue)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WriteCommandPage(characteristic: characteristic),
              ),
            );
          },
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        TextButton(
          child: const Text('NOTIFY', style: TextStyle(color: Colors.blue)),
          onPressed: () async {
            characteristic.value.listen((value) {
              setState(() {
                readValues[characteristic.uuid] = value;
              });
            });
            await characteristic.setNotifyValue(true);
          },
        ),
      );
    }

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> containers = <Widget>[];

    for (BluetoothService service in widget.services) {
      // Filter out services with UUIDs 1800 and 1801
      if (service.uuid.toString() == '00001800-0000-1000-8000-00805f9b34fb' ||
          service.uuid.toString() == '00001801-0000-1000-8000-00805f9b34fb') {
        continue;
      }

      List<Widget> characteristicsWidget = <Widget>[];

      for (BluetoothCharacteristic characteristic in service.characteristics) {
        characteristicsWidget.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(characteristic.uuid.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    ..._buildReadWriteNotifyButton(characteristic),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(child: Text('Value: ${readValues[characteristic.uuid]}')),
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
        );
      }
      containers.add(
        ExpansionTile(title: Text(service.uuid.toString()), children: characteristicsWidget),
      );
    }

    containers.add(
      ElevatedButton(
        onPressed: () async {
          await widget.device.disconnect();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bağlantı kesildi')),
          );
        },
        child: const Text('Bağlantıyı Kes'),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          ...containers,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _writeController,
              decoration: const InputDecoration(
                labelText: 'Write Value',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}