// Archivo: lib/features/dashboard/screens/unirse_proyecto_screen.dart

import 'package:flutter/material.dart';
import '../services/biomonitoreo_service.dart';

class UnirseProyectoScreen extends StatefulWidget {
  const UnirseProyectoScreen({super.key});

  @override
  State<UnirseProyectoScreen> createState() => _UnirseProyectoScreenState();
}

class _UnirseProyectoScreenState extends State<UnirseProyectoScreen> {
  // Controlador para leer lo que el usuario escribe
  final TextEditingController _codigoController = TextEditingController();
  bool _estaCargando = false;

  // Función REAL que conecta con el servidor
  Future<void> _validarCodigo() async {
    final codigo = _codigoController.text.trim();

    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un código válido.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _estaCargando = true; // Mostramos el círculo de carga
    });

    // --- LLAMADA REAL AL BACKEND ---
    final service = BiomonitoreoService();
    final resultado = await service.unirseProyecto(codigo);

    setState(() {
      _estaCargando = false; // Detenemos la carga
    });

    if (mounted) {
      if (resultado != null && resultado['exito'] == true) {
        // ¡Todo salió bien en la base de datos!
        _mostrarDialogoExito();
      } else {
        // Node.js nos rebotó (código inválido, o ya somos miembros)
        final mensajeError = resultado != null ? resultado['mensaje'] : 'Error de conexión';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensajeError), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _mostrarDialogoExito() {
    showDialog(
      context: context,
      barrierDismissible: false, // El usuario no puede cerrarlo tocando afuera
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(
          Icons.check_circle_outline,
          color: Colors.green, // Este lo dejamos verde porque es de éxito universal
          size: 60,
        ),
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
              // Quitamos los colores fijos para que el botón herede del tema (Teal)
              child: const Text(
                'Comenzar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
        child: SingleChildScrollView( 
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.group_add_outlined,
                size: 80,
                // Usamos el color primario del tema
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Ingresa el código',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Pídele al Responsable del biomonitoreo que te comparta el código de acceso (Ej. LERM-X9).',
                textAlign: TextAlign.center,
                // Usamos onSurfaceVariant para el gris dinámico
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 40),

              // Campo de texto para el código
              TextField(
                controller: _codigoController,
                textCapitalization: TextCapitalization.characters, // Fuerza mayúsculas
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: 'CÓDIGO',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // Quitamos el borde para un diseño más limpio
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  // Fondo dinámico
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),

              const SizedBox(height: 40),

              // Botón de validación o indicador de carga
              _estaCargando
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _validarCodigo,
                      style: ElevatedButton.styleFrom(
                        // Adaptamos el botón negro: Negro de día, gris claro de noche
                        backgroundColor: Theme.of(context).colorScheme.onSurface,
                        foregroundColor: Theme.of(context).colorScheme.surface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ingresar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}