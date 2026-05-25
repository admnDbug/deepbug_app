// Archivo: lib/features/profile/screens/perfil_usuario_screen.dart

import 'package:flutter/material.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class PerfilUsuarioScreen extends StatefulWidget {
  const PerfilUsuarioScreen({super.key});

  @override
  State<PerfilUsuarioScreen> createState() => _PerfilUsuarioScreenState();
}

class _PerfilUsuarioScreenState extends State<PerfilUsuarioScreen> {
  // Variables dinámicas
  String nombre = '...';
  String email = '...';
  String rol = '...';
  String institucion = '...';
  String iniciales = '--';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosPerfil();
  }

  Future<void> _cargarDatosPerfil() async {
    final authService = AuthService();
    final perfil = await authService.obtenerPerfil();

    if (perfil != null && mounted) {
      setState(() {
        nombre = perfil['nombre'] ?? 'Usuario';
        email = perfil['email'] ?? 'Sin correo';
        rol = perfil['rol'] ?? 'Colaborador';
        institucion = perfil['institucion'] ?? '';
        
        // Generar iniciales
        List<String> partes = nombre.split(' ');
        if (partes.isNotEmpty && partes[0].isNotEmpty) {
          iniciales = partes.length > 1
              ? '${partes[0][0]}${partes[1][0]}'.toUpperCase()
              : partes[0][0].toUpperCase();
        }
        isLoading = false;
      });
    } else {
      if (mounted) {
        setState(() {
          nombre = 'Error al cargar';
          email = 'Revisa tu conexión';
          isLoading = false;
        });
      }
    }
  }

  void _cerrarSesionReal() async {
    final authService = AuthService();
    await authService.logout();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  iniciales,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                nombre,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              if (institucion.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    institucion,
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
                  ),
                ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  rol,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 40),

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
                icon: Icons.security_outlined,
                title: 'Cambiar Contraseña',
                onTap: () => _mostrarSeguridad(context),
              ),

             Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return ListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: const Text('Tema de la aplicación', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_obtenerTextoModo(themeProvider.themeMode)),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () => _mostrarSelectorTema(context, themeProvider),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

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

  Widget _buildConfigTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
  void _mostrarSeguridad(BuildContext context) {
    final actualController = TextEditingController();
    final nuevaController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Seguridad', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            _buildCampoTexto(context, 'Contraseña actual', controlador: actualController, esPassword: true),
            _buildCampoTexto(context, 'Nueva contraseña', controlador: nuevaController, esPassword: true),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () async {
                final actual = actualController.text.trim();
                final nueva = nuevaController.text.trim();

                if (actual.isEmpty || nueva.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor llena ambos campos')),
                  );
                  return;
                }

                final authService = AuthService();
                final exito = await authService.cambiarPassword(actual, nueva);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(exito ? 'Contraseña actualizada' : 'Error: La contraseña actual es incorrecta'),
                      backgroundColor: exito ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Cambiar Contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarEditarDatos(BuildContext context) {
    final nombreController = TextEditingController(text: nombre);
    final institucionController = TextEditingController(text: institucion);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Editar Datos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildCampoTexto(context, 'Nombre completo', controlador: nombreController),
            _buildCampoTexto(context, 'Institución (Ej. ENCB, UNAM)', controlador: institucionController),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                initialValue: email,
                enabled: false, 
                decoration: InputDecoration(
                  labelText: 'Correo electrónico (No editable)',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () async {
                final nuevoNombre = nombreController.text.trim();
                final nuevaInstitucion = institucionController.text.trim();

                if (nuevoNombre.isEmpty || nuevaInstitucion.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor llena todos los campos editables'), backgroundColor: Colors.orange),
                  );
                  return;
                }

                final authService = AuthService();
                final exito = await authService.actualizarPerfil(nuevoNombre, nuevaInstitucion);

                if (mounted) {
                  Navigator.pop(context);
                  if (exito) {
                    _cargarDatosPerfil();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Datos actualizados exitosamente'), backgroundColor: Colors.green),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al actualizar los datos'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Actualizar Datos', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoTexto(BuildContext context, String etiqueta, {TextEditingController? controlador, bool esPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controlador,
        obscureText: esPassword,
        decoration: InputDecoration(
          labelText: etiqueta,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
        ),
      ),
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
            onPressed: () {
              Navigator.pop(context);
              _cerrarSesionReal(); 
            },
            child: const Text('Salir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _obtenerTextoModo(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return 'Seguir sistema';
      case ThemeMode.light: return 'Modo claro';
      case ThemeMode.dark: return 'Modo oscuro';
    }
  }

  void _mostrarSelectorTema(BuildContext context, ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Seguir sistema'),
              value: ThemeMode.system,
              groupValue: provider.themeMode,
              onChanged: (mode) {
                provider.setThemeMode(mode!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Modo claro'),
              value: ThemeMode.light,
              groupValue: provider.themeMode,
              onChanged: (mode) {
                provider.setThemeMode(mode!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Modo oscuro'),
              value: ThemeMode.dark,
              groupValue: provider.themeMode,
              onChanged: (mode) {
                provider.setThemeMode(mode!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}