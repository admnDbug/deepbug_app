// Archivo: lib/core/services/local_db_service.dart

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

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
  Future<void> guardarBorradorLocal({
    required String biomonitoreoId,
    required int protocoloNumero,
    required Map<String, dynamic> datosFormulario,
    required int sincronizado, // 0 = Pendiente de subir, 1 = Sincronizado con Node.js
  }) async {
    final db = await database;

    // Revisamos si ya hay un borrador de este protocolo para este proyecto
    final res = await db.query(
      'protocolos_locales',
      where: 'biomonitoreo_id = ? AND protocolo_numero = ?',
      whereArgs: [biomonitoreoId, protocoloNumero],
    );

    if (res.isNotEmpty) {
      // Si existe, lo actualizamos
      await db.update(
        'protocolos_locales',
        {
          'datos_formulario': jsonEncode(datosFormulario),
          'sincronizado': sincronizado,
          'fecha_guardado': DateTime.now().toIso8601String(),
        },
        where: 'biomonitoreo_id = ? AND protocolo_numero = ?',
        whereArgs: [biomonitoreoId, protocoloNumero],
      );
    } else {
      // Si no existe, creamos uno nuevo
      await db.insert('protocolos_locales', {
        'id': const Uuid().v4(),
        'biomonitoreo_id': biomonitoreoId,
        'protocolo_numero': protocoloNumero,
        'datos_formulario': jsonEncode(datosFormulario),
        'sincronizado': sincronizado,
        'fecha_guardado': DateTime.now().toIso8601String(),
      });
    }
  }

  // --- OBTENER BORRADOR LOCAL ---
  Future<Map<String, dynamic>?> obtenerBorradorLocal(String biomonitoreoId, int protocoloNumero) async {
    final db = await database;
    final res = await db.query(
      'protocolos_locales',
      where: 'biomonitoreo_id = ? AND protocolo_numero = ?',
      whereArgs: [biomonitoreoId, protocoloNumero],
    );

    if (res.isNotEmpty) {
      // Re-armamos el mapa decodificando el JSON de SQLite
      return {
        ...res.first,
        'datos_formulario': jsonDecode(res.first['datos_formulario'] as String),
      };
    }
    return null;
  }

  // --- BUSCAR TODOS LOS PENDIENTES DE SINCRONIZAR ---
  Future<List<Map<String, dynamic>>> obtenerPendientes() async {
    final db = await database;
    // Buscamos todos los que tengan sincronizado = 0
    final res = await db.query(
      'protocolos_locales',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );

    // Los convertimos a una lista fácil de leer para Flutter
    return res.map((item) => {
      ...item,
      'datos_formulario': jsonDecode(item['datos_formulario'] as String),
    }).toList();
  }
}