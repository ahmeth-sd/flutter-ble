// bluetooth_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothHelper {

  Future<void> startScan(Function(BluetoothDevice) onDeviceFound) async {
    var subscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        onDeviceFound(result.device);
      }
    });

    FlutterBluePlus.cancelWhenScanComplete(subscription);

    await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on).first;
    await FlutterBluePlus.startScan();
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connectToDevice(BuildContext context, BluetoothDevice device) async {
    try {
      await device.connect();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cihaza bağlandı: ${device.platformName}')),
      );
    } catch (e) {
      if (e is PlatformException && e.code != 'already_connected') {
        rethrow;
      }
    }
  }

  Future<List<BluetoothService>> discoverServices(BluetoothDevice device) async {
    return await device.discoverServices();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
    if (await Permission.location.status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}