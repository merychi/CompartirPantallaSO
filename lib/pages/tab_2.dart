import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ipProvider.dart';

class AccionesTabs extends StatelessWidget {
  const AccionesTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Color del texto
                textStyle: const TextStyle(fontSize: 28),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.phone_android,
                    size: 40,
                  ), // Icono del botón
                  Text(' Visualizar pantalla'), // Texto del botón
                ],
              ),
              onPressed: () {
                // Acción que se ejecutará al presionar el botón
                _showMessage(context);
              },
            ),
            const SizedBox(height: 50), // Espacio entre los botones
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                textStyle: const TextStyle(fontSize: 28),
                padding:
                    const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.screenshot_monitor_sharp,
                    size: 40,
                  ),
                  Text(' Controlar pantalla'),
                ],
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Servicio no disponible'),
                      content: Text(
                          'Este servicio no está disponible por el momento.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cerrar'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 50), // Espacio entre los botones
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                textStyle: const TextStyle(fontSize: 28),
                padding:
                    const EdgeInsets.symmetric(horizontal: 49, vertical: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.remove_red_eye_sharp,
                    size: 40,
                  ),
                  Text('  Ver conexiones'),
                ],
              ),
              onPressed: () {
                _showMessage(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConexionesScreen()),
    );
  }
}

//clase para la pantalla del boton ver conexiones
class ConexionesScreen extends StatefulWidget {
  const ConexionesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConexionesScreenState createState() => _ConexionesScreenState();
}

class _ConexionesScreenState extends State<ConexionesScreen> {
  final List<String> _conexiones = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conexiones'),
      ),
      body: Consumer<IpProvider>(
        builder: (context, ipProvider, child) {
          return ListView.builder(
            itemCount: ipProvider.conexiones.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(ipProvider.conexiones[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    ipProvider.removeIp(index);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
