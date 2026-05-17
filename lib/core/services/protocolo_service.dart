// Archivo: lib/core/services/protocolo_service.dart (o la ruta que prefieras)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart'; // Asegúrate de que esta ruta coincida con tu proyecto

class ProtocoloService {
  
  // --- Función para Enviar/Sincronizar Protocolos ---
  Future<bool> sincronizarProtocolo(String biomonitoreoId, int numeroProtocolo, Map<String, dynamic> datosFormulario) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return false;

      final url = Uri.parse('${ApiConstants.baseUrl}/protocolos/sincronizar');

      // Armamos el paquete exactamente como lo espera Node.js (un arreglo de protocolos)
      final bodyParams = jsonEncode({
        "protocolos": [
          {
            "biomonitoreo_id": biomonitoreoId,
            "protocolo_numero": numeroProtocolo,
            "datos_formulario": datosFormulario
          }
        ]
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
  Future<Map<String, dynamic>?> obtenerMiBorrador(String biomonitoreoId, int numeroProtocolo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return null;

      final url = Uri.parse('${ApiConstants.baseUrl}/protocolos/mi-borrador/$biomonitoreoId/$numeroProtocolo');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Retorna todo el documento
      }
      return null; // Si es 404 (no hay borrador) retorna null
    } catch (e) {
      print("Error al obtener borrador: $e");
      return null;
    }
  }

}