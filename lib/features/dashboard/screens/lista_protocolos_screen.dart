// Archivo: lib/features/dashboard/screens/lista_protocolos_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para copiar al portapapeles
import '../../protocolo5/screens/protocolo5_screen.dart';
import '../../protocolo2/screens/protocolo2_screen.dart';

class ListaProtocolosScreen extends StatelessWidget {
  final String nombreProyecto;

  const ListaProtocolosScreen({super.key, required this.nombreProyecto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nombreProyecto, style: const TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- ENCABEZADO: TÍTULO Y BOTÓN DE COLABORADORES ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombreProyecto,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  
                  // Botón interactivo para ver el Código y Colaboradores (NUESTROS COLORES)
                  InkWell(
                    onTap: () => _mostrarDetallesProyecto(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.group_outlined, color: Colors.black54, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Ver Colaboradores y Código',
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.open_in_new, color: Colors.grey, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text('Selecciona una tarea:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(height: 12),

            // --- DISEÑO DE LISTA ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildProtocoloTile(context, 'Protocolo 1', 'Datos generales de la estación', false),
                  _buildProtocoloTile(context, 'Protocolo 2', 'Evaluación visual del hábitat', true),
                  _buildProtocoloTile(context, 'Protocolo 3', 'Parámetros fisicoquímicos', false),
                  _buildProtocoloTile(context, 'Protocolo 4', 'Muestreo multihábitat', false),
                  _buildProtocoloTile(context, 'Protocolo 5', 'Análisis de muestras y BMWP/Mex', true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNCIÓN PARA MOSTRAR LA VISTA DE DETALLES  ---
  void _mostrarDetallesProyecto(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      builder: (context) {
        final double safePaddingBottom = MediaQuery.of(context).padding.bottom;

        return Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, safePaddingBottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Detalles del Proyecto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // Tarjeta del código
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Código: PRO38',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: 'PRO38'));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código copiado')));
                      },
                      icon: const Icon(Icons.copy, color: Colors.grey),
                      tooltip: 'Copiar código',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              const Text('Colaboradores', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Lista de Colaboradores
              _buildColaboradorTile('Desire Cuevas', 'desire@escom.ipn.mx'),
              _buildColaboradorTile('Didier Gonzalez', 'didier@escom.ipn.mx'),
              _buildColaboradorTile('Oscar Leyva', 'oscar@escom.ipn.mx', esResponsable: true),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Tarjeta de colaborador 
  Widget _buildColaboradorTile(String nombre, String correo, {bool esResponsable = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(correo, style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          if (esResponsable)
            const Chip(
              label: Text('Resp.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
              backgroundColor: Color(0xFFCCFF00), // Nuestro color
              side: BorderSide.none,
              padding: EdgeInsets.zero,
            )
          else
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.cancel_outlined, color: Colors.grey),
            )
        ],
      ),
    );
  }

  Widget _buildProtocoloTile(BuildContext context, String titulo, String subtitulo, bool activo) {
    return Card(
      elevation: 1,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitulo),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: activo ? const Color(0xFFCCFF00) : Colors.grey),
        onTap: () {
          if (activo) {
            if (titulo == 'Protocolo 5') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Protocolo5Screen()));
            } else if (titulo == 'Protocolo 2') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Protocolo2Screen()));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Este protocolo se implementará pronto')));
          }
        },
      ),
    );
  }
}