// Archivo: lib/features/dashboard/services/estacion_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';

class EstacionService {
  
  Future<List<dynamic>?> obtenerEstaciones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print("No hay token guardado. El usuario debe iniciar sesión.");
        return null;
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/estaciones'); 

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> estaciones = jsonDecode(response.body);
        return estaciones;
      } else {
        print("Error al obtener estaciones: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return null;
    }
  }

  Future<List<dynamic>?> obtenerZonas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return null;

      final url = Uri.parse('${ApiConstants.baseUrl}/zonas');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error al obtener zonas: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> crearestacion(String nombreEstacion, String zonaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return null;

      final url = Uri.parse('${ApiConstants.baseUrl}/estaciones'); 
      
      final bodyParams = jsonEncode({
        "nombre_estacion": nombreEstacion,
        "zona_id": zonaId
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: bodyParams,
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("Error al crear: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return null;
    }
  }
  Future<Map<String, dynamic>?> unirseEstacion(String codigo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return null;

      final url = Uri.parse('${ApiConstants.baseUrl}/estaciones/unirse');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"codigo_invitacion": codigo}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"exito": true, "mensaje": responseData['mensaje']};
      } else {
        return {"exito": false, "mensaje": responseData['mensaje'] ?? 'Error desconocido'};
      }
    } catch (e) {
      print("Error al unirse a la estacion: $e");
      return {"exito": false, "mensaje": "Error de conexión con el servidor"};
    }
  }

  Future<bool> removerColaborador(String estacionId, String colaboradorId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return false;

      final url = Uri.parse('${ApiConstants.baseUrl}/estaciones/$estacionId/remover-colaborador');
      
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"colaborador_id": colaboradorId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error al remover colaborador: $e");
      return false;
    }
  }

}