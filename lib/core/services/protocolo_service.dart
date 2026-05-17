// Archivo: lib/core/services/protocolo_service.dart (o la ruta que prefieras)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart'; // Asegúrate de que esta ruta coincida con tu proyecto

class ProtocoloService {
  
  // --- Función para Enviar/Sincronizar Protocolos ---
  // AÑADIDO: Parámetro opcional datosProtocolo5
  Future<bool> sincronizarProtocolo(String biomonitoreoId, int numeroProtocolo, Map<String, dynamic>? datosFormulario, {Map<String, dynamic>? datosProtocolo5}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return false;

      final url = Uri.parse('${ApiConstants.baseUrl}/protocolos/sincronizar');

      // Armamos el mapa dinámico respetando si es Protocolo 1-4 o Protocolo 5
      final Map<String, dynamic> protocoloData = {
        "biomonitoreo_id": biomonitoreoId,
        "datos_formulario": datosFormulario,
        "protocolo_numero": numeroProtocolo
      };

      // Si hay datos normales (Protocolos 1 al 4) los inyecta
      if (datosFormulario != null) {
        protocoloData["datos_formulario"] = datosFormulario;
      }

      // Si es el Protocolo 5, inyecta su llave especial
      if (datosProtocolo5 != null) {
        protocoloData["datos_protocolo_5"] = datosProtocolo5;
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