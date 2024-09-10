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
  final TextEditingController _commandController = TextEditingController();
  final List<String> _commandHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write Command'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _commandController,
              decoration: InputDecoration(
                labelText: 'Enter Command',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              child: Text('SEND'),
              onPressed: () async {
                String command = _commandController.text;
                await widget.characteristic.write(command.codeUnits);
                setState(() {
                  _commandHistory.add(command);
                  _commandController.clear();
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _commandHistory.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_commandHistory[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}