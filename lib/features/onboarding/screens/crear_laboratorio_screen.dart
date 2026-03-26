// Archivo: lib/features/onboarding/screens/crear_laboratorio_screen.dart

import 'package:flutter/material.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class CrearLaboratorioScreen extends StatefulWidget {
  const CrearLaboratorioScreen({super.key});

  @override
  State<CrearLaboratorioScreen> createState() => _CrearLaboratorioScreenState();
}

class _CrearLaboratorioScreenState extends State<CrearLaboratorioScreen> {
  final TextEditingController _nombreLabController = TextEditingController();
  String _institucionSeleccionada = '';
  bool _estaCargando = false;

  // Nuestra base de datos simulada de instituciones
  final List<String> _instituciones = [
    'IPN - Escuela Superior de Cómputo (ESCOM)',
    'IPN - Escuela Nacional de Ciencias Biológicas (ENCB)',
    'UNAM - FES Iztacala',
    'UNAM - Facultad de Ciencias',
    'UAM - Xochimilco',
    'SEMARNAT',
    'CONAGUA',
  ];

  Future<void> _crearLaboratorio() async {
    final nombreLab = _nombreLabController.text.trim();

    if (nombreLab.isEmpty || _institucionSeleccionada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    setState(() {
      _estaCargando = true;
    });

    // Simulamos la creación en la base de datos (Backend)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _estaCargando = false;
    });

    if (mounted) {
      _mostrarDialogoExito();
    }
  }

  void _mostrarDialogoExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.verified, color: Color(0xFF009688), size: 60),
        title: const Text('¡Laboratorio Creado!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tu espacio de trabajo ha sido configurado. Comparte este código con tu equipo para que se unan como colaboradores:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Simulamos el código de invitación que generaría el backend
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(
                'LAB-ESCOM-01',
                style: TextStyle(
                  fontSize: 20,
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
                // Navegamos al Dashboard y destruimos el historial de Onboarding
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Ir a mi Dashboard',
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
    _nombreLabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Laboratorio', style: TextStyle(fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.biotech_outlined,
                size: 80,
                color: Color(0xFF009688),
              ),
              const SizedBox(height: 24),
              const Text(
                'Configura tu espacio',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Como Responsable, podrás invitar colaboradores y administrar todos los biomonitoreos del equipo.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Campo: Nombre del Laboratorio
              TextField(
                controller: _nombreLabController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nombre del Laboratorio o Equipo',
                  hintText: 'Ej. Lab. de Ecología Dra. Eugenia',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.science_outlined),
                ),
              ),
              const SizedBox(height: 20),

              // Campo: Buscador de Instituciones (Autocomplete)
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  // Si está vacío, no mostramos sugerencias
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  // Filtramos la lista ignorando mayúsculas y acentos
                  return _instituciones.where((String opcion) {
                    return opcion.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
                  });
                },
                onSelected: (String seleccion) {
                  _institucionSeleccionada = seleccion;
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onEditingComplete) {
                      // Guardamos lo que el usuario escriba libremente, por si su escuela no está en la lista
                      controller.addListener(() {
                        _institucionSeleccionada = controller.text;
                      });

                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onEditingComplete: onEditingComplete,
                        decoration: InputDecoration(
                          labelText: 'Institución (Busca o escribe una nueva)',
                          hintText: 'Ej. IPN - ENCB',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(
                            Icons.account_balance_outlined,
                          ),
                        ),
                      );
                    },
              ),

              const SizedBox(height: 40),

              // Botón de Crear
              _estaCargando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF009688),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _crearLaboratorio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Crear Laboratorio',
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
