// Archivo: lib/features/protocolo5/models/familia_macroinvertebrado.dart

class FamiliaMacroinvertebrado {
  final String id;
  final String nombre;
  final int valor;
  final String imagenUrl;
  final String? imagenBase64; // 👈 LÍNEA AGREGADA

  FamiliaMacroinvertebrado({
    required this.id, 
    required this.nombre, 
    required this.valor, 
    required this.imagenUrl,
    this.imagenBase64, // 👈 LÍNEA AGREGADA
  });
}