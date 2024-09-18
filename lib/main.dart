import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ble/qr_code_scanner.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bluetooth_helper.dart';
import 'connected_device_page.dart'; // Import the ConnectedPage

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'BLE Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const MyHomePage(title: 'Flutter BLE Demo'),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final BluetoothHelper _bluetoothHelper = BluetoothHelper();
  BluetoothDevice? _connectedDevice;
  bool _isConnected = false;
  List<BluetoothService> _services = [];

  _initBluetooth(String macAddress) async {
    await _bluetoothHelper.startScan((device) async {
      if (device.remoteId.toString() == macAddress) {
        await _bluetoothHelper.stopScan();
        try {
          await _bluetoothHelper.connectToDevice(context, device);
          _services = await _bluetoothHelper.discoverServices(device);
          setState(() {
            _connectedDevice = device;
            _isConnected = true;
          });
          // Navigate to ConnectedDevicePage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConnectedDevicePage(device: device, services: _services),
            ),
          );
        } on PlatformException catch (e) {
          if (e.code != 'already_connected') {
            rethrow;
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    () async {
      await _bluetoothHelper.requestLocationPermission();
    }();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: Center(
      child: _isConnected
          ? Text('Bağlantı başarılı: ${_connectedDevice?.remoteId}')
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRViewExample(
                    onScanned: (macAddress) {
                      _initBluetooth(macAddress);
                    },
                  ),
                ),
              );
            },
            child: const Text('QR Kodunu Tara'),
          ),
        ],
      ),
    ),
  );
}