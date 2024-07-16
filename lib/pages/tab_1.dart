import "dart:io";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:video_call/connection/cliente_Servicio.dart";
import "package:video_call/connection/servidor_Servicio.dart";

import "../ipProvider.dart";

class InicioTabs extends StatelessWidget {
  const InicioTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(
                top: 110.0,
                bottom: 160.0,
                left: 25.0,
                right: 25.0,
              ),
              color: Colors.blue,
              child: IpComponent(),
            ),
          ),
        ],
      ),
    );
  }
}

class IpComponent extends StatefulWidget {
  const IpComponent({Key? key}) : super(key: key);

  @override
  _IpComponentState createState() => _IpComponentState();
}

class _IpComponentState extends State<IpComponent> {
  final remoteIPTextEditingController = TextEditingController();
  String _deviceIp = ''; // Ip del dispositivo actual
  String _otherIp = ''; // Ip ingresada por el usuario

  @override
  void initState() {
    super.initState();
    _getIpAddress(); // Obtener la Ip del dispositivo actual
  }

  Future<void> _getIpAddress() async {
    for (var interface in await NetworkInterface.list()) {
      _deviceIp = interface.addresses.first.address;
      setState(() {});
    }
  }

  void _saveOtherIp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Cliente2P2(
          ipAddress: remoteIPTextEditingController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Ip del dispositivo actual:',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              _deviceIp,
              style: const TextStyle(fontSize: 43, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            TextFormField(
              controller: remoteIPTextEditingController,
              style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                labelText: 'Ip del teléfono a conectar',
                labelStyle: TextStyle(fontSize: 18.0),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Por favor, ingrese una Ip válida';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (remoteIPTextEditingController.text.isNotEmpty) {
                  _saveOtherIp();
                  String remoteIP = remoteIPTextEditingController.text;
                  Provider.of<IpProvider>(context, listen: false)
                      .addIp(remoteIP);
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('La Ip ingresada no es válida'),
                        content: const Text('Ingresa una dirección IP'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Ok'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              child: const SizedBox(
                height: 30,
                child: Text(
                  'Conectar',
                  style: TextStyle(fontSize: 21),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServidorP2P( //INICIAR EL SERVIDOR
                      ipLocal: _deviceIp, // Pasar la IP local obtenida
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              child: const SizedBox(
                height: 30,
                child: Text(
                  '¿Desea Transmitir?',
                  style: TextStyle(fontSize: 21),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
