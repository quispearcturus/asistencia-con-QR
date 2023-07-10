import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asistencia App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoginFailed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            if (_isLoginFailed)
              Text(
                'Username or password is incorrect.',
                style: TextStyle(color: Colors.red),
              ),
            ElevatedButton(
              onPressed: () {
                final username = _usernameController.text;
                final password = _passwordController.text;
                if (username == 'admin' && password == '1234') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistrationPage(),
                    ),
                  );
                } else {
                  setState(() {
                    _isLoginFailed = true;
                  });
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _eventNameController = TextEditingController();

  List<Map<String, dynamic>> _registrations = [];

  void _register() {
    final id = int.tryParse(_idController.text);
    final name = _nameController.text;
    final eventName = _eventNameController.text;
    final currentTime = DateTime.now();

    final registration = {
      'id': id,
      'name': name,
      'eventName': eventName,
      'time': currentTime.toString(),
    };

    setState(() {
      _registrations.add(registration);
    });

    _idController.clear();
    _nameController.clear();
    _eventNameController.clear();
  }

  void _scanQRCode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScanPage(registerCallback: _register),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'ID',
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(
                labelText: 'Event Name',
              ),
            ),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
            ElevatedButton(
              onPressed: _scanQRCode,
              child: Text('Scan QR Code'),
            ),
            SizedBox(height: 16.0),
            Text(
              'Registered Attendees',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _registrations.length,
                itemBuilder: (context, index) {
                  final registration = _registrations[index];
                  final time = DateTime.parse(registration['time']);

                  return ListTile(
                    title: Text('ID: ${registration['id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${registration['name']}'),
                        Text('Event: ${registration['eventName']}'),
                        Text('Time: ${_formatTime(time)}'),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final formattedTime = '$hour:$minute';

    return formattedTime;
  }
}

class QRScanPage extends StatefulWidget {
  final Function registerCallback;

  QRScanPage({required this.registerCallback});

  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool scanComplete = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          if (scanComplete)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back'),
            ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      if (scanData != null && !scanComplete) {
        setState(() {
          scanComplete = true;
        });

        HapticFeedback.mediumImpact();
        controller.pauseCamera();

        widget.registerCallback();
      }
    });
  }
}
