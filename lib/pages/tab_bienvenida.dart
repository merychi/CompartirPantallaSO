import 'package:flutter/material.dart';

class PantallaBienvenida extends StatefulWidget {
  const PantallaBienvenida({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PantallaBienvenidaState createState() => _PantallaBienvenidaState();
}

class _PantallaBienvenidaState extends State<PantallaBienvenida> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin:
              const EdgeInsets.all(0), // Agrega espacio alrededor del contenido
          padding: const EdgeInsets.all(35),
          child: Column(
            // Organiza el contenido verticalmente
            mainAxisAlignment:
                MainAxisAlignment.center, // Centra el contenido verticalmente
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "¡Bienvenido a la aplicación!",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Presentamos un administrador remoto con funciones básicas, ideal para tener visión de pantallas que no sean la nuestra.",
                style: TextStyle(fontSize: 22, color: Colors.blue),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/app_home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 20,
                  ),
                  minimumSize: const Size(150, 50),
                  side: const BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                child: const Text('Entrar a la aplicación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
