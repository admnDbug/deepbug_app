// Archivo: lib/core/services/local_db_service.dart

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDBService {
  // Patrón Singleton para usar la misma conexión en toda la app
  static final LocalDBService _instance = LocalDBService._internal();
  factory LocalDBService() => _instance;
  LocalDBService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'deep_bug_local.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE protocolos_locales (
            id TEXT PRIMARY KEY,
            biomonitoreo_id TEXT,
            protocolo_numero INTEGER,
            datos_formulario TEXT,
            sincronizado INTEGER,
            fecha_guardado TEXT
          )
        ''');
      },
    );
  }

  // --- GUARDAR O ACTUALIZAR BORRADOR LOCAL ---
  // --- GUARDAR O ACTUALIZAR BORRADOR LOCAL (AISLADO POR PERFIL) ---
  Future<void> guardarBorradorLocal({
    required String biomonitoreoId,
    required int protocoloNumero,
    required Map<String, dynamic> datosFormulario,
    required int sincronizado, 
  }) async {
    final db = await database;

    // 🕵️‍♂️ Extraemos quién tiene la sesión activa actualmente
    final prefs = await SharedPreferences.getInstance();
    final String usuarioId = prefs.getString('usuario_id') ?? 'anonimo';
    
    // Creamos la firma única compuesta para este usuario y este proyecto
    final String idAisladoPorPerfil = "${usuarioId}_$biomonitoreoId";

    // Buscamos si ya existe un registro previo de este protocolo para este perfil específico
    final res = await db.query(
      'protocolos_locales',
      where: 'biomonitoreo_id = ? AND protocolo_numero = ?',
      whereArgs: [idAisladoPorPerfil, protocoloNumero],
    );

    if (res.isNotEmpty) {
      // Si ya existe, actualizamos su JSON sin tocar el de otros usuarios
      await db.update(
        'protocolos_locales',
        {
          'datos_formulario': jsonEncode(datosFormulario),
          'sincronizado': sincronizado,
          'fecha_guardado': DateTime.now().toIso8601String(),
        },
        where: 'biomonitoreo_id = ? AND protocolo_numero = ?',
        whereArgs: [idAisladoPorPerfil, protocoloNumero],
      );
    } else {
      // Si no existe, creamos un registro completamente nuevo bajo este perfil
      await db.insert('protocolos_locales', {
        'id': const Uuid().v4(),
        'biomonitoreo_id': idAisladoPorPerfil, // <-- Guardamos la llave blindada
        'protocolo_numero': protocoloNumero,
        'datos_formulario': jsonEncode(datosFormulario),
        'sincronizado': sincronizado,
        'fecha_guardado': DateTime.now().toIso8601String(),
      });
    }
  }

  // --- OBTENER BORRADOR LOCAL (FILTRADO POR PERFIL ACTIVE) ---
  Future<Map<String, dynamic>?> obtenerBorradorLocal(String biomonitoreoId, int protocoloNumero) async {
    final db = await database;

    // Revisa quién está pidiendo los datos en este milisegundo
    final prefs = await SharedPreferences.getInstance();
    final String usuarioId = prefs.getString('usuario_id') ?? 'anonimo';
    final String idAisladoPorPerfil = "${usuarioId}_$biomonitoreoId";

    final res = await db.query(
      'protocolos_locales',
      where: 'biomonitoreo_id = ? AND protocolo_numero = ?',
      whereArgs: [idAisladoPorPerfil, protocoloNumero],
    );

    if (res.isNotEmpty) {
      return {
        ...res.first,
        // IMPORTANTE: Devolvemos el biomonitoreoId original limpio a la UI para que la pantalla no note el truco
        'biomonitoreo_id': biomonitoreoId, 
        'datos_formulario': jsonDecode(res.first['datos_formulario'] as String),
      };
    }
    return null; // Si cambió de sesión y el nuevo perfil no tiene borrador, abre limpio en 0%
  }

  // --- BUSCAR TODOS LOS PENDIENTES DE SINCRONIZAR (CURE CONTRACRASH NODE) ---
  Future<List<Map<String, dynamic>>> obtenerPendientes() async {
    final db = await database;
    
    final res = await db.query(
      'protocolos_locales',
      where: 'sincronizado = 0',
    );

    // Re-armamos la lista limpiando y dividiendo la llave compuesta antes de enviarla al servicio de red
    return res.map((row) {
      final String dbId = row['biomonitoreo_id'].toString();
      
      // Si la llave local contiene el guión bajo, recortamos la primera mitad y nos quedamos con el ID real de Mongo
      final String cleanProyectoId = dbId.contains('_') ? dbId.split('_').last : dbId;

      return {
        ...row,
        'biomonitoreo_id': cleanProyectoId, // <-- El ID limpio de 24 caracteres viaja feliz a la API
        'datos_formulario': jsonDecode(row['datos_formulario'] as String),
      };
    }).toList();
  }
}