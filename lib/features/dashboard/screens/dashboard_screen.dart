// Archivo: lib/features/dashboard/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'lista_protocolos_screen.dart';
import 'unirse_proyecto_screen.dart';
import 'crear_biomonitoreo_screen.dart';
import '../../profile/screens/perfil_usuario_screen.dart';
import '../services/biomonitoreo_service.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/services/local_db_service.dart';
import '../../../core/services/protocolo_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userRole = 'Colaborador';
  String userName = 'Cargando...';
  String initials = '--';

  int _pendientesSync = 0;
  List<Map<String, dynamic>> _listaPendientes = [];
  bool _isSyncing = false;

  List<dynamic> _biomonitoreos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  Future<void> _revisarPendientesLocales() async {
    final db = LocalDBService();
    final pendientes = await db.obtenerPendientes();
    
    if (mounted) {
      setState(() {
        _listaPendientes = pendientes;
        _pendientesSync = pendientes.length;
      });
    }
  }

  // --- CARGAR PERFIL CON OFFLINE FIRST ---
  Future<void> _inicializarDatos() async {
    final authService = AuthService();
    final prefs = await SharedPreferences.getInstance();

    try {
      final perfil = await authService.obtenerPerfil();

      if (perfil != null) {
        prefs.setString('perfil_cache', jsonEncode(perfil));
        _aplicarDatosPerfil(perfil);
      } else {
        _cargarPerfilLocal(prefs);
      }
    } catch (e) {
      _cargarPerfilLocal(prefs);
    }

    await _cargarBiomonitoreos();
  }

  void _cargarPerfilLocal(SharedPreferences prefs) {
    final cache = prefs.getString('perfil_cache');
    if (cache != null) {
      _aplicarDatosPerfil(jsonDecode(cache));
    } else {
      setState(() {
        userName = 'Sin Conexión';
        initials = '--';
        userRole = 'Colaborador';
      });
    }
  }

  void _aplicarDatosPerfil(Map<String, dynamic> perfil) {
    setState(() {
      userName = perfil['nombre'] ?? 'Usuario';
      userRole = perfil['rol'] ?? 'Colaborador';

      List<String> names = userName.split(' ');
      if (names.isNotEmpty && names[0].isNotEmpty) {
        initials = names.length > 1
            ? '${names[0][0]}${names[1][0]}'.toUpperCase()
            : names[0][0].toUpperCase();
      }
    });
  }

  Future<void> _recargarTodo() async {
    await _inicializarDatos(); 
  }

  Future<void> _cargarBiomonitoreos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _revisarPendientesLocales();

    final bioService = BiomonitoreoService();
    final datosBackend = await bioService.obtenerBiomonitoreos();
    
    final prefs = await SharedPreferences.getInstance();

    if (datosBackend != null) {
      prefs.setString('proyectos_cache', jsonEncode(datosBackend));
      
      setState(() {
        _biomonitoreos = datosBackend;
        _isLoading = false;
      });
    } else {
      final cache = prefs.getString('proyectos_cache');
      
      if (cache != null) {
        setState(() {
          _biomonitoreos = jsonDecode(cache); 
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sin conexión. Mostrando proyectos guardados localmente.'), backgroundColor: Colors.blueGrey),
        );
      } else {
        setState(() {
          _errorMessage = 'No se pudieron cargar los proyectos. Verifica tu conexión.';
          _isLoading = false;
        });
      }
    }
  }

  // --- SINCRONIZAR TODO (INTEGRACIÓN INTELIGENTE PARA PROTOCOLO 5) ---
  Future<void> _sincronizarTodo() async {
    setState(() => _isSyncing = true);
    
    final cloudService = ProtocoloService();
    final localDB = LocalDBService();
    int exitos = 0;

    for (var item in _listaPendientes) {
      final int numProtocolo = item['protocolo_numero'] ?? 1;
      final Map<String, dynamic> datosForm = item['datos_formulario'] ?? {};
      bool ok = false;

      // 🕵️‍♂️ CONDICIONAL MAESTRA: Si el pendiente es el "Jefe Final" (Protocolo 5)
      if (numProtocolo == 5) {
        Map<String, dynamic>? datosP5;
        
        // Extraemos de forma segura la estructura interna que espera tu Node.js
        if (datosForm.containsKey('datos_protocolo_5')) {
          datosP5 = datosForm['datos_protocolo_5'];
        }

        // Realizamos el disparo usando el contrato oficial de tu Web original
        ok = await cloudService.sincronizarProtocolo(
          item['biomonitoreo_id'],
          numProtocolo,
          null, // datos_formulario va nulo explícitamente para el 5
          datosProtocolo5: datosP5,
        );
      } else {
        // Protocolos del 1 al 4 se sincronizan de forma tradicional
        ok = await cloudService.sincronizarProtocolo(
          item['biomonitoreo_id'],
          numProtocolo,
          datosForm,
        );
      }

      // Si el servidor dio luz verde, actualizamos SQLite localmente para este usuario
      if (ok) {
        await localDB.guardarBorradorLocal(
          biomonitoreoId: item['biomonitoreo_id'],
          protocoloNumero: numProtocolo,
          datosFormulario: datosForm,
          sincronizado: 1, // <--- Ahora sí pasará a estar limpio
        );
        exitos++;
      }
    }

    // Refrescamos contadores y la lista de proyectos en pantalla
    await _revisarPendientesLocales();
    await _cargarBiomonitoreos();
    setState(() => _isSyncing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('☁️ Sincronizados $exitos de ${_listaPendientes.length} protocolos con éxito.'),
          backgroundColor: exitos == _listaPendientes.length ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deep Bug',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PerfilUsuarioScreen(),
              ),
            ),
            borderRadius: BorderRadius.circular(50),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido, $userName',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Text(
                'Tus Proyectos Activos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              if (_pendientesSync > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_upload_outlined, color: Theme.of(context).colorScheme.onTertiaryContainer, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_pendientesSync Protocolos Locales',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Text('Tienes datos listos para subir a la nube.', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _isSyncing ? null : _sincronizarTodo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                          foregroundColor: Theme.of(context).colorScheme.onTertiary,
                        ),
                        child: _isSyncing 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Subir'),
                      ),
                    ],
                  ),
                ),

              Expanded(child: _buildListaBiomonitoreos()),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UnirseProyectoScreen(),
                    ),
                  );
                  _cargarBiomonitoreos(); 
                },
                icon: const Icon(Icons.group_add),
                label: const Text(
                  'Unirme a un Biomonitoreo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 12),

              if (userRole == 'Responsable' || userRole == 'Administrador')
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CrearBiomonitoreoScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text(
                    'Crear Nuevo Biomonitoreo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListaBiomonitoreos() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarBiomonitoreos,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_biomonitoreos.isEmpty) {
      return const Center(
        child: Text(
          'Aún no tienes proyectos asignados.\nÚnete a uno o crea uno nuevo.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _recargarTodo, 
      color: Theme.of(context).colorScheme.primary, 
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(), 
        itemCount: _biomonitoreos.length,
        itemBuilder: (context, index) {
          final proyecto = _biomonitoreos[index];

          int estadoP1 = 0;
          if (proyecto['estado_protocolos'] != null &&
              proyecto['estado_protocolos']['protocolo1'] != null) {
            estadoP1 = proyecto['estado_protocolos']['protocolo1'];
          }

          // --- ACTUALIZADO: Extracción de la zona desde zona_id ---
        String zonaText = 'Zona no especificada';
        
        if (proyecto['zona_id'] != null) {
          // Si el backend hizo el populate, zona_id será un Mapa
          if (proyecto['zona_id'] is Map) {
            zonaText = proyecto['zona_id']['nombre'] ?? 'Zona sin nombre';
          } else {
            // Si por alguna razón llega solo el ID (String)
            zonaText = 'ID: ${proyecto['zona_id'].toString().substring(0, 5)}...';
          }
        }

        return _buildProjectCard(
          context,
          proyecto['_id'].toString(),
          proyecto['nombre_proyecto'] ?? 'Proyecto Sin Nombre',
          'Activo',
          zonaText, // <--- Ahora pasamos el nombre real
          proyecto['codigo_invitacion'] ?? 'S/C',
          estadoP1,
        );
      },
    ),
  );
}

  // --- ACTUALIZADO: Recibe zonaText y code por separado ---
  Widget _buildProjectCard(
    BuildContext context,
    String id, 
    String name,
    String status,
    String zonaText,
    String code,
    int estadoP1,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.water_drop_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        // --- ACTUALIZADO: Mostramos la zona en el subtítulo ---
        subtitle: Text(
          '$status • Zona: $zonaText',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CAMBIO: Evaluamos estrictamente el estado 0 (Rojo). El naranja (1) se descarta.
            if (estadoP1 == 0) ...[
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade700,
              ),
              const SizedBox(width: 12),
            ],
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListaProtocolosScreen(
                biomonitoreoId: id, 
                nombreProyecto: name,
                estadoProtocolo1: estadoP1,
                rolUsuario: userRole,
                codigoProyecto: code, // El código sigue viajando oculto
              ),
            ),
          );
          _cargarBiomonitoreos();
        },
      ),
    );
  }
}