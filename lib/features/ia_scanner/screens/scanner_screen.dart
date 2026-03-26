// Archivo: lib/features/ia_scanner/screens/scanner_screen.dart

import 'package:flutter/material.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _estaAnalizando = false;
  String _resultado = '';

  // Esta función es el "puente" que llenarás en la Semana 4
  Future<void> _analizarInsecto() async {
    setState(() {
      _estaAnalizando = true;
      _resultado = '';
    });

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() {
      _estaAnalizando = false;
      // Resultado simulado
      _resultado = 'Baetidae (Confianza: 94.2%)';
    });

    _mostrarResultadoDialogo();
  }

  void _mostrarResultadoDialogo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // El AlertDialog heredará los colores de fondo del modo oscuro/claro automáticamente
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // 1. Ícono usando el color primario del tema
        icon: Icon(Icons.bug_report, color: Theme.of(context).colorScheme.primary, size: 50),
        title: const Text(
          'Identificación Exitosa',
          textAlign: TextAlign.center,
        ),
        content: Text(
          'La red neuronal ha clasificado el espécimen como:\n\n$_resultado\n\n¿Deseas agregarlo al Protocolo 5?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Descartar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Agregado al carrito del Protocolo 5'),
                ),
              );
            },
            // 2. Eliminamos el "style" fijo. Ahora el botón hereda el verde Teal y el texto blanco de app_theme.dart
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro MANTENIDO para resaltar la cámara
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Íconos blancos obligatorios aquí
        title: const Text(
          'Escáner Deep Bug',
          style: TextStyle(color: Colors.white), // Texto blanco obligatorio aquí
        ),
        centerTitle: true,
      ),
      // Usamos un Stack para poner la interfaz flotando sobre la cámara
      body: Stack(
        children: [
          // 1. ESPACIO PARA LA CÁMARA
          Center(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.7,
              color: Colors.grey.shade900, 
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_off_outlined,
                    color: Colors.grey,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Vista de la cámara apagada',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '(Esperando integración de paquete camera)',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // 2. GUÍAS VISUALES (El recuadro de escaneo)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                // 3. Borde usando el color primario del tema
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  // Pasamos el "context" a la función para que pueda leer el tema
                  Positioned(top: 0, left: 0, child: _construirEsquina(context)),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: RotatedBox(quarterTurns: 1, child: _construirEsquina(context)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: RotatedBox(quarterTurns: 2, child: _construirEsquina(context)),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: RotatedBox(quarterTurns: 3, child: _construirEsquina(context)),
                  ),
                ],
              ),
            ),
          ),

          // 3. INDICADOR DE CARGA
          if (_estaAnalizando)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 4. Color de carga dinámico
                    CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    const Text(
                      'Analizando características...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // 4. CONTROLES INFERIORES
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.only(bottom: 20, top: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_library, color: Colors.white, size: 30),
                      onPressed: () {},
                    ),

                    // Botón principal de escaneo
                    GestureDetector(
                      onTap: _estaAnalizando ? null : _analizarInsecto,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          // 5. Color del botón dinámico
                          color: _estaAnalizando ? Colors.grey : Theme.of(context).colorScheme.primary,
                        ),
                        child: const Icon(
                          Icons.document_scanner,
                          size: 35,
                          color: Colors.white, // Cambiado de black87 a blanco para que combine con el tema Teal
                        ),
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.flash_on, color: Colors.white, size: 30),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 6. Recibimos el BuildContext para poder leer los colores del tema
  Widget _construirEsquina(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.primary, width: 4),
          left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 4),
        ),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20)),
      ),
    );
  }
}