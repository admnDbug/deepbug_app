// Archivo: lib/features/protocolo5/providers/protocolo5_provider.dart
import 'package:flutter/material.dart';
import '../models/familia_macroinvertebrado.dart'; 

class Protocolo5Provider extends ChangeNotifier {
  final List<FamiliaMacroinvertebrado> _carrito = [];
  List<FamiliaMacroinvertebrado> get carrito => _carrito;

  int get puntajeTotal {
    int total = 0;
    for (var familia in _carrito) {
      total += familia.valor;
    }
    return total;
  }

  void agregarFamilia(FamiliaMacroinvertebrado familia) {
    _carrito.add(familia);
    notifyListeners();
  }

  void eliminarFamilia(FamiliaMacroinvertebrado familia) {
    _carrito.remove(familia);
    notifyListeners();
  }
}

// Simulamos la base de datos aquí temporalmente
final List<FamiliaMacroinvertebrado> catalogoFamilias = [
  FamiliaMacroinvertebrado(id: '1', nombre: 'Ceratopogonidae', valor: 4, imagenUrl: 'https://cdn-icons-png.flaticon.com/512/3204/3204648.png'),
  FamiliaMacroinvertebrado(id: '2', nombre: 'Chironomidae', valor: 2, imagenUrl: 'https://cdn-icons-png.flaticon.com/512/3204/3204648.png'),
  FamiliaMacroinvertebrado(id: '3', nombre: 'Baetidae', valor: 6, imagenUrl: 'https://cdn-icons-png.flaticon.com/512/3204/3204648.png'),
  FamiliaMacroinvertebrado(id: '4', nombre: 'Gerridae', valor: 5, imagenUrl: 'https://cdn-icons-png.flaticon.com/512/3204/3204648.png'),
];