// Archivo: lib/features/dashboard/screens/lista_protocolos_screen.dart

import 'package:flutter/material.dart';
import '../../protocolo1/screens/protocolo1_screen.dart';
import '../../protocolo2/screens/protocolo2_screen.dart';
import '../../protocolo3/screens/protocolo3_screen.dart';
import '../../protocolo4/screens/protocolo4_screen.dart';
import '../../protocolo5/screens/protocolo5_screen.dart'; 

class ListaProtocolosScreen extends StatefulWidget {
  final String nombreProyecto;
  final int estadoProtocolo1; 
  final String rolUsuario; 
  final String codigoProyecto;

  const ListaProtocolosScreen({
    super.key,
    required this.nombreProyecto,
    this.estadoProtocolo1 = 0,
    this.rolUsuario = 'Responsable', 
    this.codigoProyecto = 'LERM24',  
  });

  @override
  State<ListaProtocolosScreen> createState() => _ListaProtocolosScreenState();
}

class _ListaProtocolosScreenState extends State<ListaProtocolosScreen> {
  late int _estadoP1;

  // --- NUEVA LISTA DINÁMICA DE COLABORADORES ---
  List<Map<String, dynamic>> _colaboradores = [
    {'nombre': 'Oscar Leyva', 'rol': 'Responsable', 'iniciales': 'OL'},
    {'nombre': 'Didier Gonzalez', 'rol': 'Colaborador', 'iniciales': 'DS'},
    {'nombre': 'Desire Cuevas', 'rol': 'Colaborador', 'iniciales': 'DC'},
  ];

  @override
  void initState() {
    super.initState();
    _estadoP1 = widget.estadoProtocolo1;
  }

  @override
  Widget build(BuildContext context) {
    bool protocolosBloqueados = _estadoP1 == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.nombreProyecto,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTarjetaEquipo(context),
          if (_estadoP1 < 2) _buildBannerAdvertencia(),
          if (_estadoP1 < 2) const SizedBox(height: 8),
          const Text('Formularios de Campo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          _buildProtocoloTile(
            titulo: 'Protocolo 1', subtitulo: 'Plan de Monitoreo', icono: Icons.business_center_outlined, activo: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Protocolo1Screen())),
          ),
          _buildProtocoloTile(
            titulo: 'Protocolo 2', subtitulo: 'Evaluación Visual del Hábitat', icono: Icons.map_outlined, activo: !protocolosBloqueados,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Protocolo2Screen())),
          ),
          _buildProtocoloTile(
            titulo: 'Protocolo 3', subtitulo: 'Caracterización del Hábitat', icono: Icons.nature_outlined, activo: !protocolosBloqueados,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Protocolo3Screen())),
          ),
          _buildProtocoloTile(
            titulo: 'Protocolo 4', subtitulo: 'Muestreo Multihábitat', icono: Icons.pets_outlined, activo: !protocolosBloqueados,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Protocolo4Screen())),
          ),
          _buildProtocoloTile(
            titulo: 'Protocolo 5', subtitulo: 'Identificación IA (CNN)', icono: Icons.document_scanner_outlined, activo: !protocolosBloqueados,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Protocolo5Screen())), 
          ),
        ],
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
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.group_outlined, color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        title: const Text('Equipo y Accesos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text('Gestiona los colaboradores', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () => _mostrarModalEquipo(context),
      ),
    );
  }

  // --- MODAL DE EQUIPO CON STATEFUL BUILDER ---
  void _mostrarModalEquipo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        // StatefulBuilder nos permite actualizar la UI solo dentro de este Modal
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
                      const Text('Equipo del Proyecto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (widget.rolUsuario == 'Responsable') ...[
                    Text('CÓDIGO DE INVITACIÓN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.codigoProyecto, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          IconButton(
                            icon: Icon(Icons.copy, color: Theme.of(context).colorScheme.primary),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código copiado al portapapeles')));
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text('COLABORADORES (${_colaboradores.length})', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  
                  // Iteramos sobre la lista dinámica
                  ..._colaboradores.map((colab) {
                    bool esResponsable = colab['rol'] == 'Responsable';
                    return _buildColaboradorTile(
                      context,
                      colab['nombre'],
                      colab['rol'],
                      colab['iniciales'],
                      esResponsable,
                      // Lógica: Solo el Responsable puede eliminar, y no puede eliminarse a sí mismo
                      (widget.rolUsuario == 'Responsable' && !esResponsable) 
                          ? () => _confirmarEliminacion(context, colab, setModalState) 
                          : null,
                    );
                  }),
                  
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // Se añadió el parámetro 'onEliminar'
  Widget _buildColaboradorTile(BuildContext context, String nombre, String rol, String iniciales, bool esResponsable, VoidCallback? onEliminar) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: esResponsable ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Text(
          iniciales, 
          style: TextStyle(color: esResponsable ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)
        ),
      ),
      title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(rol, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      // Mostramos el ícono de basura si tenemos permiso de eliminar
      trailing: onEliminar != null 
          ? IconButton(
              icon: const Icon(Icons.person_remove_outlined, color: Colors.red),
              onPressed: onEliminar,
            )
          : null,
    );
  }

  // --- FUNCIÓN DE CONFIRMACIÓN DE ELIMINACIÓN ---
  void _confirmarEliminacion(BuildContext context, Map<String, dynamic> colaborador, StateSetter setModalState) {
    showDialog(
      context: context,
      builder: (contextDialog) => AlertDialog(
        title: const Text('Eliminar colaborador'),
        content: Text('¿Estás seguro de que deseas eliminar a ${colaborador['nombre']} de este proyecto? Ya no podrá ver ni editar los formularios.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextDialog), // Cierra el diálogo
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // 1. Actualizamos la lista usando el StateSetter del Modal
              setModalState(() {
                _colaboradores.remove(colaborador);
              });
              // 2. Cerramos el diálogo
              Navigator.pop(contextDialog);
              // 3. Mostramos la notificación
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${colaborador['nombre']} ha sido eliminado del proyecto.')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerAdvertencia() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_estadoP1 == 0) {
      return Container(
        padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: isDark ? Colors.red.shade800 : Colors.red.shade200)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700), const SizedBox(width: 12),
            const Expanded(child: Text('Protocolo 1 sin llenar. Debes planificar el monitoreo con conexión a Internet para desbloquear los demás formularios.', style: TextStyle(fontSize: 13, height: 1.4))),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: isDark ? Colors.orange.shade800 : Colors.orange.shade200)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on_outlined, color: Colors.orange.shade700), const SizedBox(width: 12),
            const Expanded(child: Text('Faltan los Datos In Situ. Abre el Protocolo 1 para registrarlos.', style: TextStyle(fontSize: 13, height: 1.4))),
          ],
        ),
      );
    }
  }

  Widget _buildProtocoloTile({required String titulo, required String subtitulo, required IconData icono, required bool activo, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: activo ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: activo ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
          child: Icon(icono, color: activo ? Theme.of(context).colorScheme.primary : Colors.grey),
        ),
        title: Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: activo ? null : Colors.grey)),
        subtitle: Text(subtitulo, style: TextStyle(color: activo ? Theme.of(context).colorScheme.onSurfaceVariant : Colors.grey)),
        trailing: Icon(activo ? Icons.arrow_forward_ios : Icons.lock_outline, size: 16, color: Colors.grey),
        onTap: () {
          if (activo) onTap();
          else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comienza por el Protocolo 1 para desbloquear.')));
        },
      ),
    );
  }
}