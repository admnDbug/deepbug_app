// Archivo: lib/features/onboarding/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import '../../dashboard/screens/unirse_proyecto_screen.dart';
import 'crear_laboratorio_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fondo gris claro
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hub_outlined, size: 80, color: Color(0xFFCCFF00)),
              const SizedBox(height: 24),
              const Text(
                '¡Bienvenido a Deep Bug!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Para comenzar a realizar biomonitoreos, necesitas pertenecer a un Laboratorio o Equipo de trabajo. ¿Qué deseas hacer?',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- OPCIÓN 1: CREAR LABORATORIO (Responsable) ---
              _buildOpcionCard(
                titulo: 'Crear un Laboratorio',
                subtitulo: 'Registra tu institución y crea un nuevo espacio de trabajo. Serás el Responsable principal.',
                icono: Icons.add_business_outlined,
                colorFondo: Colors.black87,
                colorTexto: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CrearLaboratorioScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // --- OPCIÓN 2: UNIRSE A LABORATORIO (Colaborador) ---
              _buildOpcionCard(
                titulo: 'Unirme a un Equipo',
                subtitulo: 'Ingresa el código de invitación que te proporcionó el responsable de tu laboratorio.',
                icono: Icons.group_add_outlined,
                colorFondo: Colors.white,
                colorTexto: Colors.black87,
                onTap: () {
                  // Reutilizamos la pantalla de código que hicimos en el paso anterior
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UnirseProyectoScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reciclamos el widget de tarjeta para mantener consistencia visual
  Widget _buildOpcionCard({
    required String titulo, required String subtitulo, required IconData icono,
    required Color colorFondo, required Color colorTexto, required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(16),
          border: colorFondo == Colors.white ? Border.all(color: Colors.grey.shade300) : null,
          boxShadow: [
            if (colorFondo == Colors.white)
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Icon(icono, size: 40, color: const Color(0xFFCCFF00)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorTexto)),
                  const SizedBox(height: 4),
                  Text(subtitulo, style: TextStyle(fontSize: 13, color: colorTexto.withOpacity(0.7))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: colorTexto.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }
}