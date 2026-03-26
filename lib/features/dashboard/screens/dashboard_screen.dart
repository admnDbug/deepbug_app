// Archivo: lib/features/dashboard/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'lista_protocolos_screen.dart';
import 'unirse_proyecto_screen.dart';
import 'crear_biomonitoreo_screen.dart';
import '../../profile/screens/perfil_usuario_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final String userRole = 'Responsable';
  final String userName = 'Oscar Leyva';

  void _mostrarPanelNotificaciones(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      // Eliminamos el backgroundColor: Colors.white fijo para que se adapte al modo oscuro
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Notificaciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Icon(Icons.checklist, color: Colors.grey),
                  ],
                ),
                const Divider(height: 32),
                
                _buildAlerta(Icons.warning_amber_rounded, Colors.orange, 'Protocolo 1 Pendiente', 'No olvides llenar los datos pre-campo para "Práctica Gpo 3" antes de la fecha programada.'),
                _buildAlerta(Icons.person_add_alt_1_outlined, Colors.blue, 'Nuevo Colaborador', 'Didier Gonzalez se ha unido al proyecto con el código PRO38.'),
                _buildAlerta(Icons.check_circle_outline, Colors.green, 'Sincronización Exitosa', 'Los datos del Protocolo 5 se han subido a la nube correctamente.'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlerta(IconData icono, Color color, String titulo, String mensaje) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), radius: 20, child: Icon(icono, color: color, size: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                // Eliminamos color: Colors.black87 para que sea dinámico
                Text(mensaje, style: const TextStyle(fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Eliminamos backgroundColor fijo, ahora lo toma de app_theme.dart
      appBar: AppBar(
        title: const Text('Deep Bug', style: TextStyle(fontWeight: FontWeight.bold)),
        // Eliminamos backgroundColor y color de los iconos fijos
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none), 
            onPressed: () => _mostrarPanelNotificaciones(context), 
          ),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PerfilUsuarioScreen())),
            borderRadius: BorderRadius.circular(50), 
            child: CircleAvatar(
              // Usamos el color primario del tema para el círculo
              backgroundColor: Theme.of(context).colorScheme.primary, 
              child: const Text('OL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
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
              // Usamos onSurfaceVariant para grises dinámicos
              Text('Bienvenido, $userName', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const Text('Tus Proyectos Activos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), // Sin color negro fijo
              const SizedBox(height: 20),
              
              Expanded(
                child: ListView(
                  children: [
                    _buildProjectCard(context, 'Monitoreo Río Lerma', 'En curso', 'LERM24', 0),
                    _buildProjectCard(context, 'Presa Madín - P5', 'Pendiente', 'MADN99', 2),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UnirseProyectoScreen())),
                icon: const Icon(Icons.group_add),
                label: const Text('Unirme a un Biomonitoreo', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), 
                  // El color de fondo y el texto blanco ya lo hereda del app_theme.dart
                ),
              ),
              const SizedBox(height: 12),
              
              if (userRole == 'Responsable' || userRole == 'Administrador')
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CrearBiomonitoreoScreen())),
                  icon: const Icon(Icons.add_location_alt_outlined), 
                  label: const Text('Crear Nuevo Biomonitoreo', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    // Colores dinámicos del tema
                    foregroundColor: Theme.of(context).colorScheme.primary, 
                    minimumSize: const Size(double.infinity, 50), 
                    side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, String name, String status, String code, int estadoP1) {
    // La tarjeta hereda forma, bordes y colores de app_theme.dart
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8), 
          // Color con opacidad dinámico
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), 
          child: Icon(Icons.water_drop_outlined, color: Theme.of(context).colorScheme.primary) 
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text('$status • Código: $code', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (estadoP1 < 2) Icon(Icons.warning_amber_rounded, color: estadoP1 == 0 ? Colors.red.shade700 : Colors.orange.shade700),
            if (estadoP1 < 2) const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ListaProtocolosScreen(nombreProyecto: name, estadoProtocolo1: estadoP1)));
        },
      ),
    );
  }
}