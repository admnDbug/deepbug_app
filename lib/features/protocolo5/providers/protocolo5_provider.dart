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
  
  // Catálogo dinámico que se llena desde la Base de Datos
  List<FamiliaMacroinvertebrado> _catalogoDb = [];

  List<ItemCarrito> get items => _carrito.values.toList();
  bool get estaVacio => _carrito.isEmpty;
  List<FamiliaMacroinvertebrado> get catalogo => _catalogoDb; // Mapeado para que la UI lo use como catálogo activo

  // 1. Reemplaza tu puntajeTotal por este (ahora usa double):
  double get puntajeTotal {
    double total = 0.0;
    for (var item in _carrito.values) {
      total += item.familia.valor;
    }
    return total;
  }

  // --- Indica si falta al menos una foto en el carrito ---
  bool get faltanFotos => _carrito.isNotEmpty && _carrito.values.any((item) => item.fotoBase64 == null);

  // --- ACTUALIZAR CATÁLOGO DESDE LA BD ---
  void actualizarCatalogo(List<FamiliaMacroinvertebrado> nuevoCatalogo) {
    _catalogoDb = nuevoCatalogo;
    notifyListeners();
  }

  // --- LIMPIEZA EXPLÍCITA (Evita duplicidad/mezcla entre proyectos) ---
  void clearSelectedFamilies() {
    _carrito.clear();
    notifyListeners();
  }

  // --- AGREGAR FAMILIA ---
  void agregarFamilia(FamiliaMacroinvertebrado familia, {String? fotoBase64}) {
    if (_carrito.containsKey(familia.id)) {
      _carrito[familia.id]!.cantidad++;
      if (fotoBase64 != null && _carrito[familia.id]!.fotoBase64 == null) {
        _carrito[familia.id]!.fotoBase64 = fotoBase64;
      }
    } else {
      _carrito[familia.id] = ItemCarrito(familia: familia, cantidad: 1, fotoBase64: fotoBase64);
    }
    notifyListeners();
  }

  // --- ACTUALIZAR FOTO DIRECTO DESDE EL CARRITO ---
  void actualizarFoto(String idFamilia, String fotoBase64) {
    if (_carrito.containsKey(idFamilia)) {
      _carrito[idFamilia]!.fotoBase64 = fotoBase64;
      notifyListeners();
    }
  }

  // --- REDUCIR CANTIDAD EN 1 ---
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

  // --- ELIMINAR FAMILIA POR COMPLETO ---
  void eliminarFamiliaPorCompleto(String idFamilia) {
    _carrito.remove(idFamilia);
    notifyListeners();
  }

  // --- CARGAR DATOS DESDE LOCAL DB (SQLite / Borrador) ---
  void cargarDatosDesdeAlmacenamiento(List<dynamic> datosGuardados) {
    _carrito.clear(); // Limpieza instantánea para aislar por proyecto
    for (var d in datosGuardados) {
      if (d is Map) {
        // Extraemos el nombre guardado en base de datos
        final String nombreBuscado = (d['nombre'] ?? d['nombre_familia'] ?? '').toString().toLowerCase();
        final int cant = int.tryParse(d['cantidad']?.toString() ?? '1') ?? 1;
        final String? foto = d['foto_base64']?.toString();

        // BUSQUEDA MAESTRA POR NOMBRE: Recupera el objeto del catálogo con su ID real de la app
        final fam = catalogo.firstWhere(
          (f) => f.nombre.toLowerCase() == nombreBuscado, 
          orElse: () => FamiliaMacroinvertebrado(
            id: (d['id_familia'] ?? d['familia_id'] ?? nombreBuscado).toString(), 
            nombre: d['nombre'] ?? d['nombre_familia'] ?? 'Familia', 
            valor: double.tryParse((d['valor'] ?? d['valor_bmwp'] ?? '0').toString()) ?? 0.0, 
            imagenUrl: ''
          )
        );
        
        _carrito[fam.id] = ItemCarrito(
          familia: fam, 
          cantidad: cant,
          fotoBase64: foto, 
        );
      }
    }
    notifyListeners();
  }

  // --- CONVERTIR LISTA A FORMATO JSON (Llaves idénticas a tu MongoDB) ---
  List<Map<String, dynamic>> generarJsonParaGuardar() {
    return _carrito.values.map((item) {
      // Si la foto no tiene el prefijo de datos Mime que exige Cloudinary, se lo inyectamos
      String? fotoCloudinary = item.fotoBase64;
      if (fotoCloudinary != null && !fotoCloudinary.startsWith('data:image')) {
        fotoCloudinary = 'data:image/jpeg;base64,$fotoCloudinary';
      }

      return {
        'familia_id': item.familia.id,
        'nombre_familia': item.familia.nombre, // <-- CORREGIDO: Coincide con tu MongoDB
        'valor_bmwp': item.familia.valor,     // <-- CORREGIDO: Coincide con tu MongoDB
        'cantidad': item.cantidad,
        'imagen_url': null,                     // <-- Requerido para que Node no truene antes de Cloudinary
        'foto_base64': fotoCloudinary,
      };
    }).toList();
  }
}