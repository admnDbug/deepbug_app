// Archivo: lib/features/auth/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 
import '../../../core/constants/api_constants.dart';

class AuthService {
  Future<String?> login(String email, String password) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');
      final bodyParams = jsonEncode({"email": email, "password": password});

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: bodyParams,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String token = responseData['token']; 
        
        // --- GUARDAMOS EL TOKEN EN EL TELÉFONO ---
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        // ----------------------------------------

        print("Login exitoso. Token guardado en el dispositivo.");
        return token; 
      } else {
        print("Error: Credenciales incorrectas");
        return null;
      }
    } catch (e) {
      print("Error de red: $e");
      return null;
    }
  }

  // Función para registrar un nuevo usuario (AHORA EXIGE EL CÓDIGO)
  Future<bool> registrar(String nombre, String email, String password, String institucion, {required String codigo}) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}');
      
      final bodyParams = jsonEncode({
        "nombre": nombre,
        "email": email,
        "password": password,
        "institucion": institucion,
        "codigo": codigo // <-- Mandamos el código al backend
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: bodyParams,
      );

      // Si el backend crea el usuario correctamente (201)
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData.containsKey('token')) {
          final String token = responseData['token']; 
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
        }
        
        print("Registro exitoso.");
        return true; 
      } else {
        final errorData = jsonDecode(response.body);
        print("Error al registrar: ${errorData['mensaje']}");
        return false;
      }
    } catch (e) {
      print("Error de red: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> obtenerPerfil() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return null;

      final url = Uri.parse('${ApiConstants.baseUrl}/auth/perfil');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        // Guardamos nombre y rol para acceso rápido
        await prefs.setString('user_name', userData['nombre']);
        await prefs.setString('user_role', userData['rol']);
        return userData;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Utilidad extra: Función para cerrar sesión (borrar el gafete)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Función para cambiar la contraseña desde el perfil
  Future<bool> cambiarPassword(String actual, String nueva) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return false;

      final url = Uri.parse('${ApiConstants.baseUrl}/auth/cambiar-password');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "passwordActual": actual,
          "nuevaPassword": nueva,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error al cambiar contraseña: $e");
      return false;
    }
  }

  Future<bool> actualizarPerfil(String nombre, String institucion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return false;

      final url = Uri.parse('${ApiConstants.baseUrl}/auth/actualizar-perfil');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "nombre": nombre,
          "institucion": institucion,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error al actualizar perfil: $e");
      return false;
    }
  }
}