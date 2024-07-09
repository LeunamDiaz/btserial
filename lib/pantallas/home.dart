import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _bluetooth = FlutterBluetoothSerial.instance;
  bool BTstate = false;
  bool BTconnected = false;
  BluetoothConnection? connection;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? device;

  @override
  void initState() {
    super.initState();
    permisos();
    estadoBT();
  }

  void permisos() async {
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetooth.request();
    await Permission.location.request();
  }

  void estadoBT() {
    _bluetooth.state.then((value) {
      setState(() {
        BTstate = value.isEnabled;
      });
    });

    _bluetooth.onStateChanged().listen((event) {
      switch (event) {
        case BluetoothState.STATE_ON:
          BTstate = true;
          break;
        case BluetoothState.STATE_OFF:
          BTstate = false;
          break;
        case BluetoothState.STATE_TURNING_ON:
          break;
        case BluetoothState.STATE_TURNING_OFF:
          break;
      }
      setState(() {});
    });
  }

  void encenderBT() {
    _bluetooth.requestEnable();
  }

  void apagarBT() {
    _bluetooth.requestDisable();
  }

  Widget switchBT() {
    return SwitchListTile(
      title: Text(BTstate ? 'Bluetooth Encendido' : 'Bluetooth apagado'),
      activeColor: BTstate ? Colors.blue : Colors.grey,
      tileColor: BTstate ? Colors.blue : Colors.grey,
      value: BTstate,
      onChanged: (bool value) {
        if (value) {
          encenderBT();
        } else {
          apagarBT();
        }
      },
      secondary: BTstate
          ? const Icon(Icons.bluetooth)
          : const Icon(Icons.bluetooth_disabled),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Bluetooth"),
      ),
      body: Column(
        children: <Widget>[switchBT()],
      ),
    );
  }
}
