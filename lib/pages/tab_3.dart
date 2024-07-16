import "package:flutter/material.dart";

class AtrasTabs extends StatefulWidget {
  const AtrasTabs({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AtrasTabsState createState() => _AtrasTabsState();
}

class _AtrasTabsState extends State<AtrasTabs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 390.0, left: 25.0),
          child: ElevatedButton(
            onPressed: () {
              //click del botón
              _showMessage(context);
            },
            child: const Text('Show Message'),
          ),
        ),
      ]),
    );
  }

  void _showMessage(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Boton presionado.')));
  }
}
