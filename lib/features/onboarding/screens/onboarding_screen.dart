// Archivo: lib/features/onboarding/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _codigoController = TextEditingController();

  void _validarCodigo() {
    final codigo = _codigoController.text.trim().toUpperCase();

    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un código válido.')),
      );
      return;
    }

    // --- LÓGICA SIMULADA DE CÓDIGOS ---
    String mensaje = '';
    if (codigo == 'ADMIN-ENCB') {
      mensaje = '¡Bienvenido! Rol asignado: Responsable general.';
      // Aquí en el futuro tu backend guardaría que este usuario es Admin
    } else {
      mensaje = 'Te has unido al proyecto $codigo exitosamente.';
      // Aquí se vincularía al usuario como Colaborador de ese proyecto
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));

    // Navegamos al Dashboard y borramos el historial para no poder regresar aquí
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // SingleChildScrollView soluciona el error de desbordamiento (cinta amarilla)
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Icon(
                Icons.explore_outlined,
                size: 80,
                color: Color(0xFF009688),
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Te damos la bienvenida!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Ingresa tu código de invitación para unirte a un biomonitoreo o activar tus credenciales de responsable.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // --- CAMPO DE TEXTO PARA EL CÓDIGO ---
              TextFormField(
                controller: _codigoController,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: 'EJ: PRO38',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 20,
                    letterSpacing: 0,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF009688),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- BOTÓN PRINCIPAL ---
              ElevatedButton(
                onPressed: _validarCodigo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Ingresar Código',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 24),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Explorar sin código',
                  style: TextStyle(
                    color: Colors.grey,
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
