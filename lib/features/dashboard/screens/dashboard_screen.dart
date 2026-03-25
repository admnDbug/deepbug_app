import 'package:flutter/material.dart';
import 'lista_protocolos_screen.dart';
import 'unirse_proyecto_screen.dart';
import '../../profile/screens/perfil_usuario_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final String userRole = 'Responsable';
  final String userName = 'Oscar Leyva';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deep Bug', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          // Avatar en un botón táctil
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PerfilUsuarioScreen()),
              );
            },
            borderRadius: BorderRadius.circular(50), // Para que el efecto visual del toque sea redondo
            child: const CircleAvatar(
              backgroundColor: Color(0xFFCCFF00),
              child: Text('OL', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16), // Un poco más de margen al borde de la pantalla
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bienvenido, $userName', style: const TextStyle(fontSize: 18)),
              const Text('Tus Proyectos Activos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildProjectCard(context, 'Monitoreo Río Lerma', 'En curso', 'Código: LERM24'),
                    _buildProjectCard(context, 'Presa Madín - P5', 'Pendiente', 'Código: MADN99'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UnirseProyectoScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.group_add),
                label: const Text('Unirme a un Biomonitoreo'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 10),
              if (userRole == 'Responsable' || userRole == 'Administrador')
                OutlinedButton.icon(
                  onPressed: () { print('Abriendo formulario de nuevo Biomonitoreo'); },
                  icon: const Icon(Icons.add_chart), label: const Text('Crear Nuevo Biomonitoreo'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, String name, String status, String code) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.water, color: Colors.blue),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$status • $code'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ListaProtocolosScreen(nombreProyecto: name)));
        },
      ),
    );
  }
}