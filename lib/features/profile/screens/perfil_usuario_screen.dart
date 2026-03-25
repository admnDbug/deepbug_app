// Archivo: lib/features/profile/screens/perfil_usuario_screen.dart

import 'package:flutter/material.dart';
import '../../auth/screens/login_screen.dart';
// Importamos la pantalla para unirse a proyectos/equipos
import '../../dashboard/screens/unirse_proyecto_screen.dart';

class PerfilUsuarioScreen extends StatelessWidget {
  const PerfilUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- FOTO DE PERFIL Y DATOS PRINCIPALES ---
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFCCFF00),
                child: Text(
                  'OL',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Oscar Leyva',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'oscar.leyva@escom.ipn.mx', 
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Responsable de Laboratorio',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 40),

              // --- SECCIÓN DE INFORMACIÓN Y EQUIPOS ---
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('ESPACIO DE TRABAJO ACTUAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              ),
              const SizedBox(height: 8),
              
              // 1. Tarjeta de Laboratorio (Ahora abre el selector)
              _buildConfigTile(
                icon: Icons.science_outlined,
                title: 'Laboratorio / Organización',
                subtitle: 'Desarrollo Deep Bug (ESCOM)',
                onTap: () => _mostrarSelectorLaboratorios(context), // Llama a la nueva función
              ),
              
              // 2. Tarjeta del Código (Texto actualizado para mayor claridad)
              _buildConfigTile(
                icon: Icons.qr_code_2_outlined,
                title: 'Código de Invitación (Laboratorio)',
                subtitle: 'LAB-ESCOM-01 (Toca para copiar)',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código de Laboratorio copiado al portapapeles'))
                  );
                },
              ),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text('AJUSTES DE LA CUENTA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              ),
              const SizedBox(height: 8),
              _buildConfigTile(icon: Icons.person_outline, title: 'Editar datos personales', onTap: () {}),
              _buildConfigTile(icon: Icons.notifications_none, title: 'Notificaciones', onTap: () {}),
              _buildConfigTile(icon: Icons.security_outlined, title: 'Seguridad y Contraseña', onTap: () {}),

              const SizedBox(height: 40),

              OutlinedButton.icon(
                onPressed: () => _mostrarDialogoCerrarSesion(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Deep Bug v1.0.0 (Beta)', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  // Widget reciclable
  Widget _buildConfigTile({required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _mostrarSelectorLaboratorios(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Esto ayuda a que el menú se adapte mejor si tienes muchos laboratorios
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tus Laboratorios', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Cambia de espacio de trabajo o únete a uno nuevo.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                const Divider(height: 24),

                // Laboratorio Activo
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFFCCFF00), child: Icon(Icons.science, color: Colors.black87, size: 20)),
                  title: const Text('Desarrollo Deep Bug', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Responsable • IPN ESCOM'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                  onTap: () => Navigator.pop(context),
                ),

                // Otro laboratorio simulado al que perteneces
                ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.grey.shade200, child: const Icon(Icons.science, color: Colors.grey, size: 20)),
                  title: const Text('Ecología Acuática ENCB'),
                  subtitle: const Text('Colaborador • IPN ENCB'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cambiando a Ecología Acuática...')));
                  },
                ),

                const Divider(height: 24),

                // Opciones para agregar nuevos
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.group_add, color: Colors.white, size: 20),
                  ),
                  title: const Text('Unirme a otro Laboratorio', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Usar un código de invitación'),
                  onTap: () {
                    Navigator.pop(context); // Cierra el menú inferior
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UnirseProyectoScreen()));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tendrás que volver a ingresar tu correo y contraseña para entrar a tus proyectos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Salir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}