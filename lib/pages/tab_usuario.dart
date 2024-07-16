import "package:flutter/material.dart";

class UsuariosTab extends StatelessWidget {
  const UsuariosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        Container(
            //margin: const EdgeInsets.only(top: 1000.0, left: 25.0),
            ),
        // Agregar la tarjeta UsserComponent
        SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(
              top: 110.0,
              bottom: 160.0,
              left: 25.0,
              right: 25.0,
            ),
            color: Colors.blue,
            child: const UsserComponent(), // Instanciar la clase IpComponent
          ),
        ),
      ]),
    );
  }
}

class UsserComponent extends StatefulWidget {
  const UsserComponent({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UsserComponentState createState() => _UsserComponentState();
}

//clase creada para la generacion de la tarjeta que se visualiza en la primera pestaña
class _UsserComponentState extends State<UsserComponent> {
// CODIGO del dispositivo actual
  // ignore: unused_field
  String _otherCodigo = ''; // codigo ingresado por el usuario

  Future<String> _getCodigoAddress() async {
    return Future.value('');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Para comodidad en el sistema, registre un nombre de usuario para su dispositivo.',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 50),
            TextFormField(
              style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                labelText: 'Ingrese su usuario aquí',
                labelStyle: TextStyle(fontSize: 18.0),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Ingrese su usuario aquí';
                }
                return null;
              },
              onSaved: (value) => _otherCodigo = value!,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implementar la lógica para guardar la Ip ingresada por el usuario
                _guardarUsuario();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Color del texto (foreground)
              ),
              child: const SizedBox(
                height: 30, // Set the height to 60 to make the button larger
                child: Text(
                  'Registrar',
                  style: TextStyle(
                    fontSize:
                        21, // Set the font size to 24 to make the text larger
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _guardarUsuario() {
    // Implementar la lógica para guardar la Ip ingresada por el usuario
  }
}
