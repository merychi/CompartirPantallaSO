import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

// Clase para gestionar el cliente de servicio WebSocket
class ClienteServicio {
  Socket? socket; // Instancia del socket WebSocket

  // Constructor privado para implementar el patrón Singleton
  ClienteServicio._();

  // Instancia única de la clase ClienteServicio
  static final instance = ClienteServicio._();

  // Inicializa la conexión WebSocket
  init({required String websocketUrl, required String callerId}) {
    // Crea un nuevo socket WebSocket con la URL y parámetros especificados
    //Se estará iniciando en el puerto 3000 utilizando la IP del cliente remoto.
    socket = io(websocketUrl, {
      "transports": ['websocket'], 
      "query": {"callerId": callerId} 
    });
    return socket; 
  }

  // Cierra la conexión WebSocket
  close() {
    print("Un cliente se ha desconectado");
    socket?.close(); // Cierra el socket WebSocket si existe
  }
}


// Clase para el widget de cliente peer-to-peer (P2P)
class Cliente2P2 extends StatefulWidget {
  final String ipAddress;   // Dirección IP del cliente
  final dynamic offer;    // Oferta SDP
  const Cliente2P2({super.key, this.offer, required this.ipAddress});

  @override
  State<Cliente2P2> createState() => _Cliente2P2State(); // Crea el estado del widget
}


// Estado del widget Cliente2P2
class _Cliente2P2State extends State<Cliente2P2> {
  bool isAudioOn = true, isVideoOn = true;  // Estados de audio y video

  Socket? socket; // Instancia del socket WebSocket
  String _callerId = ""; // ID del solicitante de transmision

  final _remoteRTCVideoRenderer = RTCVideoRenderer(); // Renderizador de video remoto
  RTCPeerConnection? _rtcPeerConnection; // Conexión de pares WebRTC
  List<RTCIceCandidate> rtcIceCadidates = []; // Lista de candidatos ICE

  @override
  void initState() {
    super.initState();
    
    _remoteRTCVideoRenderer.initialize(); // Inicializa el renderizador de video remoto

    _callerId = generarStringNumerico(6); // Genera un ID numérico para el que solicita la transmision.
                                          //Se evita utilizar la IP ya que esta es cambiante según la red.

    // Inicializa el servicio cliente WebSocket con la URL y ID del llamador
    socket = ClienteServicio.instance.init(
        websocketUrl: "http://${widget.ipAddress}:3000", callerId: _callerId);

    // Maneja el evento de desconexión del socket WebSocket
    socket!.on("disconnect", (data) {
      // Muestra un diálogo de alerta al detectar la desconexión
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('¡INTRUSO DETECTADO!'),
            content: const Text("      No se admite tu supervisión"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    });
  
    // Maneja el evento de error de conexión del socket WebSocket
  socket!.on("connect_error", (data) {
    // Desconecta el socket WebSocket en caso de error
    socket!.disconnect();
    print("Sucedio un error inesperado con la IP");

    // Muestra un diálogo de alerta indicando el error de conexión
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error de Conexión'),
          content: const Text('No se pudo conectar con el servidor.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  });

  // Configura la conexión de pares WebRTC
  _setupPeerConnection();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // Configuración inicial del peer connection utilizando WebRTC
_setupPeerConnection() async {
  // Crear la conexión de pares WebRTC con servidores ICE (STUN)
  _rtcPeerConnection = await createPeerConnection({
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  });

  // Manejar el evento de recepción de flujo de video
  _rtcPeerConnection!.onTrack = (event) {
    _remoteRTCVideoRenderer.srcObject = event.streams[0];
    setState(() {}); // Actualizar la interfaz de usuario para mostrar el nuevo flujo de video
  };

  // Manejar el evento de candidato ICE recibido
  _rtcPeerConnection!.onIceCandidate = (RTCIceCandidate candidate) => rtcIceCadidates.add(candidate);

  // Escuchar la respuesta de transmisión del otro extremo (callee)
  socket!.on("transmisionRespuesta", (data) async {
    // Establecer la descripción remota recibida como respuesta
    await _rtcPeerConnection!.setRemoteDescription(
      RTCSessionDescription(
        data["sdpAnswer"]["sdp"],
        "answer",
      ),
    );

    // Enviar todos los candidatos ICE recolectados al otro extremo
    for (RTCIceCandidate candidate in rtcIceCadidates) {
      socket!.emit("IceCandidate", {
        "calleeId": '1',
        "iceCandidate": {
          "id": candidate.sdpMid,
          "label": candidate.sdpMLineIndex,
          "candidate": candidate.candidate
        }
      });
    }
  });

  // Crear una oferta de transmisión desde este extremo 
  RTCSessionDescription offer = await _rtcPeerConnection!.createOffer();
  await _rtcPeerConnection!.setLocalDescription(offer);

  // Enviar la oferta de transmisión al otro extremo 
  socket!.emit('crearTransmision', {
    "calleeId": '1',
    "sdpOffer": offer.toMap(),
  });
}

// Método para detener la transmisión y cerrar la aplicación
_detenerTransmision() {
  SystemNavigator.pop();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(widget.ipAddress),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration:
                      BoxDecoration(color: Colors.white.withOpacity(0.5)),
                  child: Stack(children: [
                    RTCVideoView(
                      _remoteRTCVideoRenderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _detenerTransmision,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 57, 136, 150), // Color de fondo del botón
                    ),
                    child: Text(
                      'Salir de la transmisión',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white), // Ajusta el tamaño y color del texto
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  String generarStringNumerico(int i) {
    const numeros = '123456789';
    Random random = Random();
    String stringNumerico = '';
    for (int i = 0; i < 6; i++) {
      int indiceAleatorio = random.nextInt(numeros.length);
      stringNumerico += numeros[indiceAleatorio];
    }
    return stringNumerico;
  }
}
