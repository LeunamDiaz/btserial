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
  String contenido = '';

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
      setState(() {
        switch (event) {
          case BluetoothState.STATE_ON:
            BTstate = true;
            break;
          case BluetoothState.STATE_OFF:
            BTstate = false;
            break;
          case BluetoothState.STATE_TURNING_ON:
          case BluetoothState.STATE_TURNING_OFF:
            break;
        }
      });
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
      title: Text(BTstate ? 'Bluetooth Encendido' : 'Bluetooth Apagado'),
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

  Widget infoDisp() {
    return ListTile(
      title: device == null ? Text("Sin Dispositivo") : Text(device?.name ?? "Desconocido"),
      subtitle: device == null ? Text("Sin Dispositivo") : Text(device?.address ?? "Desconocido"),
      trailing: BTconnected
          ? IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await connection?.finish();
          setState(() {
            BTconnected = false;
            devices = [];
            device = null;
          });
        },
      )
          : IconButton(
        icon: const Icon(Icons.search),
        onPressed: listarDispositivos,
      ),
    );
  }

  Future<void> listarDispositivos() async {
    devices = await _bluetooth.getBondedDevices();
    debugPrint(devices.toString());
    setState(() {});
  }

  Widget lista() {
    if (BTconnected) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Text(
          contenido,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 10.0,
            letterSpacing: 1,
            wordSpacing: 1,
          ),
        ),
      );
    } else {
      return devices.isEmpty
          ? const Text("No hay dispositivos")
          : ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(devices[index].name ?? "Desconocido"),
            subtitle: Text(devices[index].address),
            trailing: IconButton(
              icon: const Icon(Icons.bluetooth_connected),
              onPressed: () async {
                connection = await BluetoothConnection.toAddress(devices[index].address);
                recibirDatos();
                setState(() {
                  device = devices[index];
                  BTconnected = true;
                  recibirDatos();
                  setState(() {

                  });
                });
              },
            ),
          );
        },
      );
    }
  }

  void recibirDatos() {
    connection?.input?.listen((event) {
      contenido = String.fromCharCodes(event);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Bluetooth"),
      ),
      body: Column(
        children: <Widget>[
          switchBT(),
          const Divider(height: 5),
          infoDisp(),
          Expanded(child: lista()),
        ],
      ),
    );
  }
}
