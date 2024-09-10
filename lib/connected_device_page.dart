// lib/connected_device_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'write_command_page.dart';

class ConnectedDevicePage extends StatefulWidget {
  final BluetoothDevice device;
  final List<BluetoothService> services;

  ConnectedDevicePage({required this.device, required this.services});

  @override
  _ConnectedDevicePageState createState() => _ConnectedDevicePageState();
}

class _ConnectedDevicePageState extends State<ConnectedDevicePage> {
  final String targetServiceUuid = "61583a86-393d-4c5e-a37c-a6975e4f5eda"; // Replace with your target service UUID
  final String targetCharacteristicUuid = "ccb61b8e-f42b-47ad-9da9-cfc1c275b107"; // Replace with your target characteristic UUID

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToWriteCommandPage();
    });
  }

  void _navigateToWriteCommandPage() {
    final targetService = widget.services.firstWhere(
          (service) => service.uuid.toString() == targetServiceUuid,
    );

    if (targetService != null) {
      final targetCharacteristic = targetService.characteristics.firstWhere(
            (characteristic) => characteristic.uuid.toString() == targetCharacteristicUuid,
      );

      if (targetCharacteristic != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WriteCommandPage(characteristic: targetCharacteristic),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected to ${widget.device.remoteId}'),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}