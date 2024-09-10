// lib/write_command_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class WriteCommandPage extends StatefulWidget {
  final BluetoothCharacteristic characteristic;

  WriteCommandPage({required this.characteristic});

  @override
  _WriteCommandPageState createState() => _WriteCommandPageState();
}

class _WriteCommandPageState extends State<WriteCommandPage> {
  bool _isOn = false;

  void _sendCommand(String command) async {
    await widget.characteristic.write(command.codeUnits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write Command'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                'assets/logo.png', // Ensure this path matches the actual location of your logo
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 10),
            SwitchListTile(
              title: Text(
                _isOn ? 'Turn Off' : 'Turn On',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Tap to toggle',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              value: _isOn,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.red.withOpacity(0.5),
              onChanged: (bool value) {
                setState(() {
                  _isOn = value;
                  _sendCommand(_isOn ? '1' : '0');
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}