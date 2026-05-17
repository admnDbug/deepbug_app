// Archivo: lib/features/dashboard/screens/lista_protocolos_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <--- VITAL para el Clipboard
import '../../protocolo1/screens/protocolo1_screen.dart';
import '../../protocolo2/screens/protocolo2_screen.dart';
import '../../protocolo3/screens/protocolo3_screen.dart';
import '../../protocolo4/screens/protocolo4_screen.dart';
import '../../protocolo5/screens/protocolo5_screen.dart';
import '../services/biomonitoreo_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ListaProtocolosScreen extends StatefulWidget {
  final String biomonitoreoId;
  final String nombreProyecto;
  final int estadoProtocolo1;
  final String rolUsuario;
  final String codigoProyecto;

  const ListaProtocolosScreen({
    super.key,
    required this.biomonitoreoId,
    required this.nombreProyecto,
    this.estadoProtocolo1 = 0,
    required this.rolUsuario,
    required this.codigoProyecto,
  });

  @override
  State<ListaProtocolosScreen> createState() => _ListaProtocolosScreenState();
}

class _ListaProtocolosScreenState extends State<ListaProtocolosScreen> {
  late int _estadoP1;
  List<Map<String, dynamic>> _colaboradores = [];
  String _miRolEnEsteProyecto = 'Colaborador';

  @override
  void initState() {
    super.initState();
    _estadoP1 = widget.estadoProtocolo1;
    _recargarEstadoProyecto();
  }

  String _obtenerIniciales(String nombre) {
    if (nombre.trim().isEmpty) return '--';
    List<String> partes = nombre.trim().split(' ');
    if (partes.length > 1) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return partes[0][0].toUpperCase();
  }

  Future<void> _recargarEstadoProyecto() async {
    final bioService = BiomonitoreoService();
    List<dynamic>? datosBackend = await bioService.obtenerBiomonitoreos();
    final prefs = await SharedPreferences.getInstance();

    if (datosBackend == null) {
      final cache = prefs.getString('proyectos_cache');
      if (cache != null) datosBackend = jsonDecode(cache);
    }

    String miId = '';
    final perfilCache = prefs.getString('perfil_cache');
    if (perfilCache != null) {
      final miPerfil = jsonDecode(perfilCache);
      miId = miPerfil['id']?.toString() ?? miPerfil['_id']?.toString() ?? '';
    }

    if (datosBackend != null) {
      final proyectoActualizado = datosBackend.firstWhere(
        (p) =>
            p['_id'].toString() == widget.biomonitoreoId ||
            p['nombre_proyecto'] == widget.nombreProyecto,
        orElse: () => null,
      );

      if (proyectoActualizado != null && mounted) {
        List<Map<String, dynamic>> equipoDinamico = [];
        bool soyResponsableDeEsteProyecto = false;

        for (var resp in (proyectoActualizado['responsable_id'] ?? [])) {
          String idResp = '';
          if (resp is Map) {
            idResp = resp['_id'].toString();
            equipoDinamico.add({
              'id': idResp,
              'nombre': resp['nombre'] ?? 'Usuario Desconocido',
              'rol': 'Responsable',
              'iniciales': _obtenerIniciales(resp['nombre'] ?? ''),
            });
          } else {
            idResp = resp.toString();
            equipoDinamico.add({
              'id': idResp,
              'nombre': 'Cargando...',
              'rol': 'Responsable',
              'iniciales': '--',
            });
          }
          if (idResp == miId) {
            soyResponsableDeEsteProyecto = true;
          }
        }

        for (var colab in (proyectoActualizado['colaboradores_id'] ?? [])) {
          if (colab is Map) {
            equipoDinamico.add({
              'id': colab['_id'],
              'nombre': colab['nombre'] ?? 'Usuario Desconocido',
              'rol': 'Colaborador',
              'iniciales': _obtenerIniciales(colab['nombre'] ?? ''),
            });
          } else {
            equipoDinamico.add({
              'id': colab.toString(),
              'nombre': 'Cargando...',
              'rol': 'Colaborador',
              'iniciales': '--',
            });
          }
        }

        setState(() {
          _colaboradores = equipoDinamico;
          _miRolEnEsteProyecto = soyResponsableDeEsteProyecto ? 'Responsable' : 'Colaborador';

          if (proyectoActualizado['estado_protocolos'] != null &&
              proyectoActualizado['estado_protocolos']['protocolo1'] != null) {
            _estadoP1 = proyectoActualizado['estado_protocolos']['protocolo1'];
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // CAMBIO CLAVE: Los candados de bloqueo lógicos se eliminan. Todos los protocolos quedan activos.
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.nombreProyecto,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _recargarEstadoProyecto,
        color: Theme.of(context).colorScheme.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildTarjetaEquipo(context),
            if (_estadoP1 < 2) _buildBannerAdvertencia(),
            if (_estadoP1 < 2) const SizedBox(height: 8),
            const Text(
              'Formularios de Campo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildProtocoloTile(
              titulo: 'Protocolo 1',
              subtitulo: 'Plan de Monitoreo',
              icono: Icons.business_center_outlined,
              activo: true,
              onTap: () async {
                // Pasamos el nombre del proyecto para que se pueda autollenar si es virgen
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Protocolo1Screen(
                      biomonitoreoId: widget.biomonitoreoId,
                      nombreProyectoInicial: widget.nombreProyecto,
                    ),
                  ),
                );
                await _recargarEstadoProyecto();
              },
            ),
            _buildProtocoloTile(
              titulo: 'Protocolo 2',
              subtitulo: 'Evaluación Visual del Hábitat',
              icono: Icons.map_outlined,
              activo: true, // Siempre abierto
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Protocolo2Screen(biomonitoreoId: widget.biomonitoreoId)
                ),
              ),
            ),
            _buildProtocoloTile(
              titulo: 'Protocolo 3',
              subtitulo: 'Caracterización del Hábitat',
              icono: Icons.nature_outlined,
              activo: true, // Siempre abierto
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Protocolo3Screen(biomonitoreoId: widget.biomonitoreoId),
                ),
              ),
            ),
            _buildProtocoloTile(
              titulo: 'Protocolo 4',
              subtitulo: 'Muestreo Multihábitat',
              icono: Icons.pets_outlined,
              activo: true, // Siempre abierto
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Protocolo4Screen(biomonitoreoId: widget.biomonitoreoId),
                ),
              ),
            ),
            _buildProtocoloTile(
              titulo: 'Protocolo 5',
              subtitulo: 'Identificación IA (CNN)',
              icono: Icons.document_scanner_outlined,
              activo: true, // Siempre abierto
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Protocolo5Screen(biomonitoreoId: widget.biomonitoreoId),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaEquipo(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.group_outlined, color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        title: const Text('Equipo y Accesos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text('Gestiona los colaboradores', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () => _mostrarModalEquipo(context),
      ),
    );
  }

  void _mostrarModalEquipo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Equipo del Proyecto', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_miRolEnEsteProyecto == 'Responsable') ...[
                    Text(
                      'CÓDIGO DE INVITACIÓN',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.codigoProyecto,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                          ),
                          // CAMBIO CLAVE: Se implementa la copia física al portapapeles nativo
                          IconButton(
                            icon: Icon(Icons.copy, color: Theme.of(context).colorScheme.primary),
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: widget.codigoProyecto));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('¡Código copiado al portapapeles! 📋'), backgroundColor: Colors.green),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text(
                    'COLABORADORES (${_colaboradores.length})',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),

                  ..._colaboradores.map((colab) {
                    bool esResponsable = colab['rol'] == 'Responsable';
                    return _buildColaboradorTile(
                      context,
                      colab['nombre'],
                      colab['rol'],
                      colab['iniciales'],
                      esResponsable,
                      (_miRolEnEsteProyecto == 'Responsable' && !esResponsable)
                          ? () => _confirmarEliminacion(context, colab, setModalState)
                          : null,
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildColaboradorTile(BuildContext context, String nombre, String rol, String iniciales, bool esResponsable, VoidCallback? onEliminar) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: esResponsable ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Text(iniciales, style: TextStyle(color: esResponsable ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
      title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(rol, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      trailing: onEliminar != null
          ? IconButton(icon: const Icon(Icons.person_remove_outlined, color: Colors.red), onPressed: onEliminar)
          : null,
    );
  }

  void _confirmarEliminacion(BuildContext context, Map<String, dynamic> colaborador, StateSetter setModalState) {
    showDialog(
      context: context,
      builder: (contextDialog) => AlertDialog(
        title: const Text('Eliminar colaborador'),
        content: Text('¿Estás seguro de que deseas eliminar a ${colaborador['nombre']} de este proyecto? Ya no podrá ver ni editar los formularios.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(contextDialog), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(contextDialog);
              final service = BiomonitoreoService();
              final exito = await service.removerColaborador(widget.biomonitoreoId, colaborador['id']);

              if (exito) {
                setModalState(() { _colaboradores.remove(colaborador); });
                _recargarEstadoProyecto();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${colaborador['nombre']} ha sido eliminado.'), backgroundColor: Colors.green),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerAdvertencia() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Conservamos ÚNICAMENTE la advertencia crítica roja (Planificación incompleta)
    if (_estadoP1 == 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? Colors.red.shade800 : Colors.red.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Planificación incompleta en este dispositivo. Puedes abrir el Protocolo 1 para cargar los datos base del proyecto.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      );
    } 
    
    // Si el estado es 1 (In Situ naranja) o 2 (Completado), ocultamos el banner por completo
    return const SizedBox.shrink();
  }

  Widget _buildProtocoloTile({required String titulo, required String subtitulo, required IconData icono, required bool activo, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitulo, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap, // Al remover los candados lógicos, ejecuta directo la función de navegación
      ),
    );
  }
}