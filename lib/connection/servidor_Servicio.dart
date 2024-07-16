import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io/socket_io.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class Servidor {
  //Varibles para acceder al servidor desde otra clase
  Servidor._();
  static final instance = Servidor._();
  Server? _server;

  //Listas de clientes conectados.
  List<String> clientesConectados =
      []; // Lista para almacenar direcciones IP de clientes
  List<String> get conectadosClientes => clientesConectados;

  //Iniciar el servidor.
  init() {
    _server = Server();
    _server!.listen(3000);
    print("Servidor escuchando conexiones en el puerto 3000");
    return _server;
  }

  //Cerrar el servidor.
  close() {
    print("El servidor se ha cerrado");
    _server!.close();
  }
}

class ServidorP2P extends StatefulWidget {
  final dynamic offer; // Oferta de sesión (SDP) para la conexión P2P
  final String ipLocal; // Dirección IP local del servidor
  const ServidorP2P({super.key, this.offer, required this.ipLocal});

  @override
  State<ServidorP2P> createState() => _ServidorP2PState();
}

class _ServidorP2PState extends State<ServidorP2P> {
  String ip = '';
  bool _isMicOn = false;             
  bool _pantallaCompartidaOn = true; 

  dynamic incomingSDPOffer; // Oferta de sesión (SDP) entrante
  Server? _server;         // Instancia de un servidor para la comunicación P2P

  final _rtcVideoRenderer =RTCVideoRenderer(); // Renderizador de video para WebRTC
  MediaStream? _mediaStream;                  // Flujo de medios para la comunicación WebRTC
  RTCPeerConnection? _rtcPeerConnection;      // Conexión que permite conectar dos pares WebRTC

  List<RTCIceCandidate> rtcIceCadidate =
      []; // Lista de candidatos ICE para la negociación WebRTC

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _toggleScreenShare() {
    _pantallaCompartidaOn =
        !_pantallaCompartidaOn; // Alterna el estado de compartir pantalla

    _mediaStream?.getVideoTracks().forEach((track) {
      track.enabled =
          _pantallaCompartidaOn; // Habilita o deshabilita los tracks de video según el estado de compartir pantalla
    });

    setState(() => {}); 
  }

  @override
  void initState() {

    ip = widget.ipLocal;                                    // Asigna la dirección IP local recibida desde el widget padre

    _rtcVideoRenderer.initialize();                        // Inicializa el renderizador de video para WebRTC

    _server = Servidor.instance.init();                   // Inicializa el servidor de señalización para WebRTC

    // Configura la lógica del servidor cuando se establece una conexión
    _server!.on("connection", (socket) {
      String codeId = socket.handshake['query']
          ['codeId'];                                   // ID del que solicita la transmision obtenido desde el handshake
      socket.join(codeId);                              // El socket se une al ID del codeId
      Servidor.instance.clientesConectados.add(ip);    // Agrega la IP a la lista de clientes conectados

      print("SERVIDOR: Se ha añadido el cliente $ip a la lista de servidores conectados");

      // Maneja la solicitud para crear una nueva transmisión
      socket.on("crearTransmision", (data) {
        var sdpOffer = data['sdpOffer']; // Oferta SDP recibida desde el cliente

        if (mounted) {
          setState(() => incomingSDPOffer = {
                "codeId": codeId,
                "sdpOffer": sdpOffer,
              });

          _aceptarTransmision(); // Acepta la transmisión utilizando la oferta SDP recibida
        }
      });

      // Maneja eventos relacionados con candidatos ICE recibidos
      socket.on("IceCandidate", (data) {
        String candidate = data["iceCandidate"]["candidate"]; // Candidato ICE
        String sdpMid = data["iceCandidate"]["id"]; // ID SDP
        int sdpMLineIndex =
            data["iceCandidate"]["label"]; // Índice de línea SDP

        // Añade el candidato ICE al objeto de conexión de pares WebRTC
        _rtcPeerConnection!.addCandidate(RTCIceCandidate(
          candidate,
          sdpMid,
          sdpMLineIndex,
        ));
      });
    });

    _setupPeerConnection(); // Configura la conexión de pares WebRTC
    super.initState();      // Llama al método initState de la clase base
  }

  // Configura la conexión de pares WebRTC
  _setupPeerConnection() async {
    // Configura el servicio en segundo plano como foreground para mantener la conexión activa
    FlutterBackgroundService().invoke('setAsForeground');

    // Crea una conexión de pares WebRTC con servidores ICE configurados
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

    // Maneja el evento cuando se añade una pista de transmisión
    _rtcPeerConnection!.onTrack = (event) {
      // Establece el objeto fuente del renderizador de video con la transmisión recibida
      _rtcVideoRenderer.srcObject = event.streams[0];
      setState(() {}); 
    };

    // Obtiene el media stream para compartir pantalla y micrófono
    _mediaStream = await navigator.mediaDevices
        .getDisplayMedia({'video': _pantallaCompartidaOn, 'audio': _isMicOn});

    // Añade las pistas del media stream al objeto de conexión de pares WebRTC
    _mediaStream!.getTracks().forEach((track) {
      _rtcPeerConnection!.addTrack(track, _mediaStream!);
    });

    // Establece el objeto fuente del renderizador de video con el media stream
    _rtcVideoRenderer.srcObject = _mediaStream;
    setState(() {}); 
  }

// Acepta una transmisión WebRTC entrante
  _aceptarTransmision() async {
    // Establece la descripción remota recibida en la conexión de pares WebRTC
    await _rtcPeerConnection!.setRemoteDescription(
      RTCSessionDescription(
        incomingSDPOffer["sdpOffer"]["sdp"],
        incomingSDPOffer["sdpOffer"]["type"],
      ),
    );

    // Crea una respuesta SDP para la conexión de pares WebRTC
    RTCSessionDescription answer = await _rtcPeerConnection!.createAnswer();

    // Establece la descripción local como la respuesta SDP creada
    _rtcPeerConnection!.setLocalDescription(answer);

    // Envía la respuesta SDP al llamador utilizando el servidor de señalización
    _server!.to(incomingSDPOffer["codeId"]).emit("transmisionRespuesta", {
      "callee": '1',
      "sdpAnswer": answer.toMap(),
    });

    // Actualiza el estado para indicar que ya no hay una oferta SDP entrante
    setState(() {
      incomingSDPOffer = null;
    });
  }

// Detiene la transmisión y cierra la conexión
  _detenerTransmision(BuildContext ctx) {
    // Remueve la IP de la lista de clientes conectados en el servidor de señalización
    Servidor.instance.clientesConectados.remove(ip);
    SystemNavigator.pop(); // Cierra la aplicación
  }

  @override
  Widget build(BuildContext context) {
    const styleText = TextStyle(
        fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white);
    final circularButton = ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20), backgroundColor: Colors.white);

    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [
                    ElevatedButton(
                      onPressed: () {
                        _detenerTransmision(context);
                      },
                      style: circularButton,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              width:
                                  10), // Ajusta el espacio entre el icono y el texto
                          Text(
                            'Cortar transmisión',
                            style: TextStyle(
                                fontSize:
                                    16), // Puedes ajustar el tamaño del texto aquí
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _isMicOn = false;
    _pantallaCompartidaOn = true;
    _mediaStream?.getTracks().forEach((track) {
      track.stop();
    });
    _mediaStream?.dispose();
    _rtcPeerConnection!.close();
    Servidor.instance.close();
  }
}
