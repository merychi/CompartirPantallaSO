/* ARCHIVO: ARCHIVO PRINCIPAL DE LA APLICACIÓN*/


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_call/pages/tab_1.dart';
import 'package:video_call/pages/tab_2.dart';
import 'package:video_call/pages/tab_3.dart';
import 'package:video_call/pages/tab_bienvenida.dart';
import 'package:video_call/pages/tab_usuario.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import 'ipProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IpProvider()),
      ],
      child: PantallaInicial(),
    ),
  );
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  try {
    await service.configure(
        iosConfiguration: IosConfiguration(),
        androidConfiguration: AndroidConfiguration(
            onStart: onStart,
            autoStart: true,
            autoStartOnBoot: true,
            isForegroundMode: true));

    await service.startService();
  } catch (e) {
    print(e);
  }
}

 void updateForegroundNotification(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      service.setForegroundNotificationInfo(
        title: "Hoy hace un buen día",
        content: "Un muy lindo día",
      );
    }
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
      updateForegroundNotification(service);
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

 

  service.invoke('setAsForeground');
}

class PantallaInicial extends StatelessWidget {
  PantallaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(),
      ),
      themeMode: ThemeMode.dark,
      home:PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  _PantallaPrincipalState createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  bool _isDarkMode = false; // Estado para almacenar el tema actual

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) =>
            const PantallaBienvenida(), // Pantalla de bienvenida
        '/app_home': (context) => DefaultTabController(
            length: 4,
            child: Scaffold(
                appBar: AppBar(
                  title: const Text('Administrador Remoto',
                      style: TextStyle(
                          fontSize: 24)), // Aumenta el tamaño del título

                  bottom: const TabBar(
                    indicatorColor: Colors.blue,
                    labelStyle: TextStyle(
                        fontSize:
                            15), // Aumenta el tamaño del texto // Aumenta el tamaño de los iconos
                    tabs: <Widget>[
                      Tab(
                        icon: Icon(Icons.supervised_user_circle_sharp),
                        text: "Usuarios",
                      ),
                      Tab(
                        icon: Icon(Icons.home),
                        text: "Inicio",
                      ),
                      Tab(
                        icon: Icon(Icons.connected_tv),
                        text: "Acciones",
                      ),
                      Tab(
                        icon: Icon(Icons.settings),
                        text: "Opciones",
                      ),
                    ],
                  ),
                ),
                body: const TabBarView(
                  children: <Widget>[
                    UsuariosTab(),
                    InicioTabs(),
                    AccionesTabs(),
                    AtrasTabs()
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isDarkMode = !_isDarkMode; // Cambia el estado del tema
                    });
                  },
                  child: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                ))) // Tu pantalla principal con pestañas
        //
      },
      theme: _isDarkMode
          ? ThemeData.dark()
          : ThemeData.light(), // Cambia el tema según el estado
    );
  }
}
