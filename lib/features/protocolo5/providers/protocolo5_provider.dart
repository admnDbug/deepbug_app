// Archivo: lib/features/protocolo5/providers/protocolo5_provider.dart
import 'package:flutter/material.dart';
import '../models/familia_macroinvertebrado.dart'; 

class ItemCarrito {
  final FamiliaMacroinvertebrado familia;
  int cantidad;
  String? fotoBase64; // Guardaremos la evidencia fotográfica aquí

  ItemCarrito({required this.familia, this.cantidad = 1, this.fotoBase64});
}

class Protocolo5Provider extends ChangeNotifier {
  final Map<String, ItemCarrito> _carrito = {};

  List<ItemCarrito> get items => _carrito.values.toList();
  bool get estaVacio => _carrito.isEmpty;

  int get puntajeTotal {
    int total = 0;
    for (var item in _carrito.values) {
      total += item.familia.valor;
    }
    return total;
  }

  // --- Indica si falta al menos una foto en el carrito ---
  bool get faltanFotos => _carrito.isNotEmpty && _carrito.values.any((item) => item.fotoBase64 == null);

  // --- MODIFICADO: Acepta la foto opcionalmente ---
  void agregarFamilia(FamiliaMacroinvertebrado familia, {String? fotoBase64}) {
    if (_carrito.containsKey(familia.id)) {
      _carrito[familia.id]!.cantidad++;
      // Si la IA mandó foto y antes no tenía, se la asignamos
      if (fotoBase64 != null && _carrito[familia.id]!.fotoBase64 == null) {
        _carrito[familia.id]!.fotoBase64 = fotoBase64;
      }
    } else {
      _carrito[familia.id] = ItemCarrito(familia: familia, fotoBase64: fotoBase64);
    }
    notifyListeners();
  }

  // --- NUEVO: Permite tomar la foto directo desde el carrito ---
  void actualizarFoto(String idFamilia, String fotoBase64) {
    if (_carrito.containsKey(idFamilia)) {
      _carrito[idFamilia]!.fotoBase64 = fotoBase64;
      notifyListeners();
    }
  }

  void reducirCantidad(String idFamilia) {
    if (_carrito.containsKey(idFamilia)) {
      if (_carrito[idFamilia]!.cantidad > 1) {
        _carrito[idFamilia]!.cantidad--;
      } else {
        _carrito.remove(idFamilia); 
      }
      notifyListeners();
    }
  }

  void eliminarFamiliaPorCompleto(String idFamilia) {
    _carrito.remove(idFamilia);
    notifyListeners();
  }

  void cargarDesdeBorrador(List<dynamic> datosGuardados) {
    _carrito.clear();
    for (var d in datosGuardados) {
      final fam = catalogoFamilias.firstWhere((f) => f.id == d['id_familia'], 
          orElse: () => FamiliaMacroinvertebrado(id: d['id_familia'], nombre: d['nombre'], valor: d['valor'], imagenUrl: ''));
      
      _carrito[fam.id] = ItemCarrito(
        familia: fam, 
        cantidad: d['cantidad'] ?? 1,
        fotoBase64: d['foto_base64'], // Recupera la foto si estaba en offline
      );
    }
    notifyListeners();
  }

  // --- MODIFICADO: Prepara el JSON incluyendo la foto en Base64 ---
  List<Map<String, dynamic>> generarJsonParaGuardar() {
    return _carrito.values.map((item) => {
      'id_familia': item.familia.id,
      'nombre': item.familia.nombre,
      'valor': item.familia.valor,
      'cantidad': item.cantidad,
      'foto_base64': item.fotoBase64, 
    }).toList();
  }
}

// Catálogo temporal con las nuevas familias
final List<FamiliaMacroinvertebrado> catalogoFamilias = [
  FamiliaMacroinvertebrado(id: '1', nombre: 'Baetidae', valor: 6, imagenUrl: 'https://cdn-icons-png.flaticon.com/512/3204/3204648.png'),
  FamiliaMacroinvertebrado(id: '2', nombre: 'Caenidae', valor: 4, imagenUrl: 'https://cdn-icons-png.flaticon.com/512/3204/3204648.png'),
  FamiliaMacroinvertebrado(id: '3', nombre: 'Heptageniidae', valor: 10, imagenUrl: 'https://cdn-icons-png.flaticon.com/512/3204/3204648.png'),
  FamiliaMacroinvertebrado(id: '4', nombre: 'Leptohyphidae', valor: 5, imagenUrl: 'https://cdn-icons-png.flaticon.com/512/3204/3204648.png'),
  FamiliaMacroinvertebrado(id: '5', nombre: 'Leptophlebiidae', valor: 10, imagenUrl: 'https://cdn-icons-png.flaticon.com/512/3204/3204648.png'),
  FamiliaMacroinvertebrado(id: '6', nombre: 'Ceratopogonidae', valor: 4, imagenUrl: 'https://cdn-icons-png.flaticon.com/512/3204/3204648.png'),
];