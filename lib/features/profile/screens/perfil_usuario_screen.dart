// Archivo: lib/features/profile/screens/perfil_usuario_screen.dart

import 'package:flutter/material.dart';
import '../../auth/screens/login_screen.dart';

class PerfilUsuarioScreen extends StatelessWidget {
  const PerfilUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Quitamos backgroundColor fijo
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        // Quitamos backgroundColor y elevation fijos (los toma del app_theme)
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- FOTO DE PERFIL Y DATOS ---
              CircleAvatar(
                radius: 50,
                // Color primario dinámico
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Text(
                  'OL',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Oscar Leyva',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'oscar.leyva@escom.ipn.mx',
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),

              // --- BADGE DE ROL ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  // Usamos un color secundario/terciario para que resalte elegante en ambos modos
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Responsable',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- AJUSTES DE LA CUENTA ---
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'AJUSTES DE LA CUENTA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              _buildConfigTile(
                context,
                icon: Icons.person_outline,
                title: 'Editar datos personales',
                onTap: () => _mostrarEditarDatos(context),
              ),
              _buildConfigTile(
                context,
                icon: Icons.notifications_none,
                title: 'Preferencias de Notificaciones',
                onTap: () => _mostrarAjustesNotificaciones(context),
              ),
              _buildConfigTile(
                context,
                icon: Icons.security_outlined,
                title: 'Cambiar Contraseña',
                onTap: () => _mostrarSeguridad(context),
              ),

              // Tile de Modo Oscuro adaptado a CardTheme
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                // Quitamos color, elevation y shape para que lo herede de app_theme.dart
                child: SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined), // Sin color fijo
                  title: const Text('Modo Oscuro', style: TextStyle(fontWeight: FontWeight.bold)),
                  value: false, // <-- Esto lo controlaremos con Provider en la Semana 4
                  activeColor: Theme.of(context).colorScheme.primary, // Color primario
                  onChanged: (bool value) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La conexión del tema manual requiere Provider. Se implementará en la Semana 4.')));
                  },
                ),
              ),

              const SizedBox(height: 40),

              // --- CERRAR SESIÓN ---
              OutlinedButton.icon(
                onPressed: () => _mostrarDialogoCerrarSesion(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Deep Bug v1.0.0 (Beta)',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Se agrega BuildContext para heredar estilos si se requiere
  Widget _buildConfigTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      // Quitamos colores y bordes fijos, CardTheme se encarga
      child: ListTile(
        leading: Icon(icon), // Sin color fijo
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), // Sin color fijo
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // --- MODALES DE CONFIGURACIÓN ---

  void _mostrarEditarDatos(BuildContext context) {
    _mostrarModalBase(context, 'Editar Datos Personales', [
      _buildCampoTexto(context, 'Nombre completo', inicial: 'Oscar Leyva'),
      _buildCampoTexto(context, 'Correo electrónico', inicial: 'oscar.leyva@escom.ipn.mx'),
      _buildCampoTexto(context, 'Teléfono (Opcional)', inicial: ''),
      const SizedBox(height: 16),
      _buildBotonGuardar(context, 'Actualizar Datos'),
    ]);
  }

  void _mostrarAjustesNotificaciones(BuildContext context) {
    _mostrarModalBase(context, 'Notificaciones', [
      Text(
        'Elige qué alertas deseas recibir en tu dispositivo.',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 16),
      SwitchListTile(
        title: const Text('Nuevos colaboradores se unen'),
        value: true,
        activeColor: Theme.of(context).colorScheme.primary,
        onChanged: (v) {},
      ),
      SwitchListTile(
        title: const Text('Recordatorios de Protocolo 1'),
        value: true,
        activeColor: Theme.of(context).colorScheme.primary,
        onChanged: (v) {},
      ),
      SwitchListTile(
        title: const Text('Actualizaciones de la plataforma'),
        value: false,
        activeColor: Theme.of(context).colorScheme.primary,
        onChanged: (v) {},
      ),
      const SizedBox(height: 16),
      _buildBotonGuardar(context, 'Guardar Preferencias'),
    ]);
  }

  void _mostrarSeguridad(BuildContext context) {
    _mostrarModalBase(context, 'Seguridad', [
      _buildCampoTexto(context, 'Contraseña actual', esPassword: true),
      _buildCampoTexto(context, 'Nueva contraseña', esPassword: true),
      _buildCampoTexto(context, 'Confirmar nueva contraseña', esPassword: true),
      const SizedBox(height: 16),
      _buildBotonGuardar(context, 'Cambiar Contraseña'),
    ]);
  }

  void _mostrarModalBase(BuildContext context, String titulo, List<Widget> contenido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Quitamos backgroundColor: Colors.white para que el modo oscuro pinte su fondo oscuro
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...contenido,
          ],
        ),
      ),
    );
  }

  Widget _buildCampoTexto(BuildContext context, String etiqueta, {String inicial = '', bool esPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: inicial,
        obscureText: esPassword,
        decoration: InputDecoration(
          labelText: etiqueta,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest, // Color dinámico
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Quitamos borde base 
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2), // Borde enfocado primario
          ),
        ),
      ),
    );
  }

  Widget _buildBotonGuardar(BuildContext context, String texto) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$texto exitosamente')));
      },
      style: ElevatedButton.styleFrom(
        // Quitamos backgroundColor y foregroundColor fijos
        padding: const EdgeInsets.symmetric(vertical: 16),
        // La forma (shape) ya la está heredando del app_theme, pero si quieres asegurarla:
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(texto, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tendrás que volver a ingresar tus credenciales.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            ),
            child: const Text('Salir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}