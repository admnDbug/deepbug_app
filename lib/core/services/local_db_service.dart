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
      version: 2, 
      onCreate: (db, version) async {
        await _crearTablas(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS protocolos_locales');
        await _crearTablas(db);
      },
    );
  }

  Future<void> _crearTablas(Database db) async {
    await db.execute('''
      CREATE TABLE protocolos_locales (
        id TEXT PRIMARY KEY,
        estacion_id TEXT,
        protocolo_numero INTEGER,
        datos_formulario TEXT,
        sincronizado INTEGER,
        fecha_guardado TEXT
      )
    ''');
  }

  Future<void> guardarBorradorLocal({
    required String estacionId,
    required int protocoloNumero,
    required Map<String, dynamic> datosFormulario,
    required int sincronizado,
  }) async {
    final db = await database;

    final prefs = await SharedPreferences.getInstance();
    final String usuarioId = prefs.getString('usuario_id') ?? 'anonimo';

    final String idAisladoPorPerfil = "${usuarioId}_$estacionId";

    final res = await db.query(
      'protocolos_locales',
      where: 'estacion_id = ? AND protocolo_numero = ?',
      whereArgs: [idAisladoPorPerfil, protocoloNumero],
    );

    if (res.isNotEmpty) {
      await db.update(
        'protocolos_locales',
        {
          'datos_formulario': jsonEncode(datosFormulario),
          'sincronizado': sincronizado,
          'fecha_guardado': DateTime.now().toIso8601String(),
        },
        where: 'estacion_id = ? AND protocolo_numero = ?',
        whereArgs: [idAisladoPorPerfil, protocoloNumero],
      );
    } else {
      // Si no existe, creamos un registro completamente nuevo bajo este perfil
      await db.insert('protocolos_locales', {
        'id': const Uuid().v4(),
        'estacion_id': idAisladoPorPerfil, 
        'protocolo_numero': protocoloNumero,
        'datos_formulario': jsonEncode(datosFormulario),
        'sincronizado': sincronizado,
        'fecha_guardado': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<Map<String, dynamic>?> obtenerBorradorLocal(
    String estacionId,
    int protocoloNumero,
  ) async {
    final db = await database;

    // Revisa quién está pidiendo los datos en este milisegundo
    final prefs = await SharedPreferences.getInstance();
    final String usuarioId = prefs.getString('usuario_id') ?? 'anonimo';
    final String idAisladoPorPerfil = "${usuarioId}_$estacionId";

    final res = await db.query(
      'protocolos_locales',
      where: 'estacion_id = ? AND protocolo_numero = ?',
      whereArgs: [idAisladoPorPerfil, protocoloNumero],
    );

    if (res.isNotEmpty) {
      return {
        ...res.first,
        'estacion_id': estacionId,
        'datos_formulario': jsonDecode(res.first['datos_formulario'] as String),
      };
    }
    return null; // Si cambió de sesión y el nuevo perfil no tiene borrador, abre limpio en 0%
  }

  Future<List<Map<String, dynamic>>> obtenerPendientes() async {
    final db = await database;

    final res = await db.query('protocolos_locales', where: 'sincronizado = 0');

    return res.map((row) {
      final String dbId = row['estacion_id'].toString();

      // Si la llave local contiene el guión bajo, recortamos la primera mitad y nos quedamos con el ID real de Mongo
      final String cleanEstacionId = dbId.contains('_')
          ? dbId.split('_').last
          : dbId;

      return {
        ...row,
        'estacion_id':
            cleanEstacionId, 
        'datos_formulario': jsonDecode(row['datos_formulario'] as String),
      };
    }).toList();
  }
}
