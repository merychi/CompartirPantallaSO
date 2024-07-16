/* ARCHIVO IPPROVIDER: PERMITE ACTUALIZAR EN TIEMPO REAL LA LISTA 
DE SERVIDORES A LOS QUE HA INGRESADO EL CLIENTE PARA OBSERVAR SU PANTALLA.
*/

import 'package:flutter/material.dart';

class IpProvider with ChangeNotifier {
  List<String> _conexiones = [];

  List<String> get conexiones => _conexiones;

  void addIp(String ip) {
    _conexiones.add(ip);
    notifyListeners();
  }

  void removeIp(int index) {
    _conexiones.removeAt(index);
    notifyListeners();
  }
}
