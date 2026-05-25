// Archivo: lib/core/services/protocolo_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class ProtocoloService {
  
  // --- Función para Enviar/Sincronizar Protocolos ---
  Future<bool> sincronizarProtocolo(String estacionId, int numeroProtocolo, Map<String, dynamic>? datosFormulario, {Map<String, dynamic>? datosProtocolo5}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return false;

      final url = Uri.parse('${ApiConstants.baseUrl}/protocolos/sincronizar');

      // ¡CORRECCIÓN CRÍTICA! La llave del JSON ahora es estacion_id
      final Map<String, dynamic> protocoloData = {
        "estacion_id": estacionId, 
        "datos_formulario": datosFormulario,
        "protocolo_numero": numeroProtocolo
      };

      if (datosFormulario != null) {
        protocoloData["datos_formulario"] = datosFormulario;
      }

      // Si es el Protocolo 5, inyecta su llave especial
      if (datosProtocolo5 != null) {
        protocoloData["datos_protocolo_5"] = datosProtocolo5;
        protocoloData["datos_formulario"] = null; // P5 no usa este campo
      }

      final bodyParams = jsonEncode({
        "protocolos": [protocoloData]
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: bodyParams,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Protocolo $numeroProtocolo sincronizado con éxito en la BD.");
        return true;
      } else {
        print("Error al sincronizar protocolo: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error de red al sincronizar protocolo: $e");
      return false;
    }
  }

  // --- Función para obtener el borrador previo ---
  Future<Map<String, dynamic>?> obtenerMiBorrador(String estacionId, int numeroProtocolo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return null;

      // URL actualizada con la nueva nomenclatura
      final url = Uri.parse('${ApiConstants.baseUrl}/protocolos/mi-borrador/$estacionId/$numeroProtocolo');

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
      print("Error al obtener borrador: $e");
      return null;
    }
  }
}