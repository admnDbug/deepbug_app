// Archivo: lib/features/dashboard/screens/crear_biomonitoreo_screen.dart

import 'package:flutter/material.dart';

class CrearBiomonitoreoScreen extends StatefulWidget {
  const CrearBiomonitoreoScreen({super.key});

  @override
  State<CrearBiomonitoreoScreen> createState() =>
      _CrearBiomonitoreoScreenState();
}

class _CrearBiomonitoreoScreenState extends State<CrearBiomonitoreoScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _rioController = TextEditingController();
  bool _estaCargando = false;

  void _generarBiomonitoreo() async {
    if (_nombreController.text.isEmpty) return;
    setState(() => _estaCargando = true);

    // Simula petición al backend
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _estaCargando = false);

    _mostrarExito('PRO-ENCB-88'); // Código simulado
  }

  void _mostrarExito(String codigo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          Icons.check_circle,
          // 1. Usamos el color primario dinámico en lugar de Color(0xFF009688)
          color: Theme.of(context).colorScheme.primary,
          size: 60,
        ),
        title: const Text('Biomonitoreo Creado', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Comparte este código con tus colaboradores para que se unan al proyecto:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                // 2. Fondo dinámico: gris claro de día, gris oscuro de noche
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                codigo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cierra diálogo
                Navigator.pop(context); // Regresa al Dashboard
              },
              // El diseño del botón ya lo toma de app_theme.dart
              child: const Text(
                'Ir al Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nuevo Biomonitoreo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.add_location_alt_outlined,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Inicia un nuevo proyecto',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Como Responsable, se generará un código único para que tu equipo se integre.',
              // Usamos un color secundario del tema para el subtítulo
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre o Identificador del Proyecto',
                hintText: 'Ej. Salida Práctica Gpo 3',
                filled: true,
                // Fondo dinámico
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                prefixIcon: const Icon(Icons.folder_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none, // Quitamos borde base para que sea más limpio
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    // Borde enfocado usando color primario dinámico
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _rioController,
              decoration: InputDecoration(
                labelText: 'Nombre del Río / Afluente (Opcional)',
                hintText: 'Ej. Río Magdalena',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                prefixIcon: const Icon(Icons.water_drop_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            _estaCargando
                ? Center(
                    // 3. CircularProgressIndicator usa el color primario
                    child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                  )
                : ElevatedButton(
                    onPressed: _generarBiomonitoreo,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      // Quitamos color de fondo, lo hereda del tema
                    ),
                    child: const Text(
                      'Generar Código y Crear',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}