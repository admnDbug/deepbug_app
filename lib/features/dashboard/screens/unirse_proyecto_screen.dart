// Archivo: lib/features/dashboard/screens/unirse_proyecto_screen.dart

import 'package:flutter/material.dart';

class UnirseProyectoScreen extends StatefulWidget {
  const UnirseProyectoScreen({super.key});

  @override
  State<UnirseProyectoScreen> createState() => _UnirseProyectoScreenState();
}

class _UnirseProyectoScreenState extends State<UnirseProyectoScreen> {
  // Controlador para leer lo que el usuario escribe
  final TextEditingController _codigoController = TextEditingController();
  bool _estaCargando = false;

  // Función que simula la validación del código en el servidor
  Future<void> _validarCodigo() async {
    final codigo = _codigoController.text.trim();

    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un código válido.')),
      );
      return;
    }

    setState(() {
      _estaCargando = true; // Mostramos el círculo de carga
    });

    // Simulamos que la app va a internet a buscar el código (tarda 2 segundos)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _estaCargando = false;
    });

    if (mounted) {
      // Mostramos el mensaje de éxito 
      _mostrarDialogoExito();
    }
  }

  void _mostrarDialogoExito() {
    showDialog(
      context: context,
      barrierDismissible: false, // El usuario no puede cerrarlo tocando afuera
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
        title: const Text('¡Código Autorizado!', textAlign: TextAlign.center),
        content: const Text(
          'Te has unido exitosamente al biomonitoreo como Colaborador. Ya puedes empezar a llenar los protocolos.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Cerramos el diálogo
                Navigator.pop(context);
                // Regresamos al Dashboard (cerrando esta pantalla)
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCCFF00),
                foregroundColor: Colors.black87,
              ),
              child: const Text('Comenzar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codigoController.dispose(); // Siempre limpiamos la memoria
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unirse a Proyecto', style: TextStyle(fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.group_add_outlined, size: 80, color: Color(0xFFCCFF00)),
              const SizedBox(height: 24),
              const Text(
                'Ingresa el código',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Pídele al Responsable del biomonitoreo que te comparta el código de acceso (Ej. LERM-X9).',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              // Campo de texto para el código
              TextField(
                controller: _codigoController,
                textCapitalization: TextCapitalization.characters, // Fuerza mayúsculas
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                decoration: InputDecoration(
                  hintText: 'CÓDIGO',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Botón de validación o indicador de carga
              _estaCargando
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFCCFF00)))
                  : ElevatedButton(
                      onPressed: _validarCodigo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Ingresar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}