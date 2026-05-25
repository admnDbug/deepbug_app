// Archivo: lib/features/auth/screens/registro_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../dashboard/screens/dashboard_screen.dart'; // Importante: Asegúrate de que esta ruta sea correcta

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  bool _ocultarPassword = true;
  bool _isLoading = false;

  // Controladores para capturar el texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _institucionController = TextEditingController(); 
  final TextEditingController _codigoController = TextEditingController(); // NUEVO: Controlador del código

  // Función maestra de registro
  void _crearCuenta() async {
    // Validaciones básicas: AHORA EL CÓDIGO ES OBLIGATORIO
    if (_nombreController.text.trim().isEmpty || 
        _emailController.text.trim().isEmpty || 
        _passwordController.text.trim().isEmpty || 
        _institucionController.text.trim().isEmpty ||
        _codigoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos, incluyendo el código de invitación'), backgroundColor: Colors.orange),
      );
      return;
    }

    FocusScope.of(context).unfocus(); // Ocultar teclado
    setState(() => _isLoading = true); // Iniciar carga

    final authService = AuthService();
    
    // Asumiendo que tu AuthService ahora devuelve un Map (o un booleano si adaptaste el servicio)
    // Si tu servicio devuelve true/false, y ya no devuelve el rol, la validación de abajo será más sencilla.
    // Aquí asumo que devuelve un booleano basado en tu código original, pero modificado para enviar el código.
    // Asegúrate de que tu `AuthService.registrar` acepta el parámetro 'codigo' como vimos en el paso anterior.
    final resultado = await authService.registrar(
      _nombreController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _institucionController.text.trim(),
      codigo: _codigoController.text.trim(), // Enviamos el código al backend
    );

    setState(() => _isLoading = false); // Detener carga

    if (resultado == true && mounted) { // O 'if (exito && mounted)' dependiendo de cómo dejaste tu AuthService
      // ¡Magia lista! Como ya validamos el código en el backend,
      // el usuario ya tiene rol de Responsable o Colaborador.
      // Nos vamos directo al Dashboard. ¡Adiós Onboarding!
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (Route<dynamic> route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar. Verifica tu código de invitación o si el correo ya existe.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _institucionController.dispose();
    _codigoController.dispose(); // No olvides disponer el nuevo controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context), 
                ),
              ),
              Icon(
                Icons.person_add_alt_1_outlined,
                size: 80,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              const Text('Crear Cuenta', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Únete a una estacion ingresando tu código', textAlign: TextAlign.center),
              const SizedBox(height: 40),

              // --- FORMULARIO CON CONTROLADORES ---
              TextField(
                controller: _nombreController, 
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 20),            
              
              TextField(
                controller: _institucionController, 
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Institución (Ej. ENCB, UNAM)',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.school_outlined),
                ),
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: _emailController, 
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: _passwordController, 
                obscureText: _ocultarPassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_ocultarPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- NUEVO CAMPO OBLIGATORIO: CÓDIGO DE INVITACIÓN ---
              TextField(
                controller: _codigoController,
                textCapitalization: TextCapitalization.characters, // Ideal para códigos
                decoration: InputDecoration(
                  labelText: 'Código de Invitación',
                  hintText: 'Ej. BIO-1234',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                  // Destacar ligeramente el campo
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- BOTÓN DE CARGA ---
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _crearCuenta, 
                  child: _isLoading 
                      ? const CircularProgressIndicator() 
                      : const Text('Registrarme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Ya tienes una cuenta?'),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Inicia Sesión', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}