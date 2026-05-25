// Archivo: lib/features/dashboard/screens/crear_estacion_screen.dart

import 'package:flutter/material.dart';
import '../services/estacion_service.dart';
import 'dashboard_screen.dart';

class CrearEstacionScreen extends StatefulWidget {
  const CrearEstacionScreen({super.key});

  @override
  State<CrearEstacionScreen> createState() => _CrearEstacionScreenState();
}

class _CrearEstacionScreenState extends State<CrearEstacionScreen> {
  final TextEditingController _nombreController = TextEditingController();
  
  List<dynamic> _zonas = [];
  String? _zonaSeleccionadaId;
  
  bool _isLoadingZonas = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _cargarZonasDisponibles();
  }

  Future<void> _cargarZonasDisponibles() async {
    final service = EstacionService();
    final zonasDesdeBackend = await service.obtenerZonas();

    if (mounted) {
      setState(() {
        _zonas = zonasDesdeBackend ?? [];
        _isLoadingZonas = false;
      });
    }
  }

  void _crearEstacion() async {
    final nombre = _nombreController.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un nombre para la estacion.'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_zonaSeleccionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar una Zona Geográfica.'), backgroundColor: Colors.orange),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final service = EstacionService();
    final resultado = await service.crearestacion(nombre, _zonaSeleccionadaId!);

    setState(() => _isSubmitting = false);

    if (resultado != null && mounted) {
      final codigoGenerado = resultado['Estacion']['codigo_invitacion'];
      
      // Mostramos el código de invitación generado por el backend
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('¡Estacion Creado!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Comparte este código con tus colaboradores para que se unan:'),
              const SizedBox(height: 16),
              Text(
                codigoGenerado,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Cerramos el diálogo y regresamos al Dashboard recargado
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear la estacion. Intenta de nuevo.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva estacion', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.add_location_alt_outlined, size: 80, color: colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Crear estacion',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Define el nombre y el lugar donde se realizará el muestreo.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nombre de la Estacion',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.science_outlined),
                ),
              ),
              const SizedBox(height: 20),

              _isLoadingZonas 
                ? const Center(child: CircularProgressIndicator())
                : _zonas.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'No hay Zonas Geográficas disponibles. Un Administrador debe crear una zona antes de poder iniciar una estacion.',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Zona Geográfica',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.map_outlined),
                      ),
                      items: _zonas.map<DropdownMenuItem<String>>((zona) {
                        return DropdownMenuItem<String>(
                          // El valor que se envía al backend es el _id
                          value: zona['_id'].toString(), 
                          child: Text(zona['nombre']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _zonaSeleccionadaId = newValue;
                        });
                      },
                    ),
                    
              const Padding(
                padding: EdgeInsets.only(top: 8.0, left: 4.0, bottom: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Si la zona de muestreo no está en la lista, el administrador debe crearla desde el sitio web.',
                        style: TextStyle(
                          color: Colors.grey, 
                          fontSize: 12, 
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting || _zonas.isEmpty ? null : _crearEstacion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2))
                      : const Text('Crear Estacion y Generar Código', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}