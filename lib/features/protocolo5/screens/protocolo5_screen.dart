// Archivo: lib/features/protocolo5/screens/protocolo5_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importamos el Provider y el Modelo que creamos en los pasos anteriores
import '../providers/protocolo5_provider.dart';
import '../models/familia_macroinvertebrado.dart';

// --- PANTALLA PRINCIPAL DEL PROTOCOLO 5 (ELECCIÓN DE MÉTODO) ---
class Protocolo5Screen extends StatelessWidget {
  const Protocolo5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Protocolo5Provider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        title: const Text('Protocolo 5', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Índice BMWP/Mex', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text(
                          'Puntaje: ${provider.puntajeTotal}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _mostrarCarrito(context, provider),
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text('${provider.carrito.length}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCCFF00),
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              const Text(
                '¿Cómo deseas agregar las familias?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              _buildOpcionCard(
                titulo: 'Clasificar con IA',
                subtitulo: 'Usa la cámara para identificar el macroinvertebrado automáticamente.',
                icono: Icons.document_scanner_outlined,
                colorFondo: Colors.black87,
                colorTexto: Colors.white,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Módulo CNN pendiente...')),
                  );
                },
              ),

              const SizedBox(height: 16),

              _buildOpcionCard(
                titulo: 'Selección Manual',
                subtitulo: 'Explora el catálogo de familias y selecciona visualmente el espécimen.',
                icono: Icons.touch_app_outlined,
                colorFondo: Colors.white,
                colorTexto: Colors.black87,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CatalogoManualScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpcionCard({
    required String titulo, required String subtitulo, required IconData icono,
    required Color colorFondo, required Color colorTexto, required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(16),
          border: colorFondo == Colors.white ? Border.all(color: Colors.grey.shade300) : null,
          boxShadow: [
            if (colorFondo == Colors.white)
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Icon(icono, size: 40, color: const Color(0xFFCCFF00)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorTexto)),
                  const SizedBox(height: 4),
                  Text(subtitulo, style: TextStyle(fontSize: 13, color: colorTexto.withOpacity(0.7))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: colorTexto.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }
}

// --- 2. PANTALLA SECUNDARIA (EL CATÁLOGO TIPO E-COMMERCE) ---
class CatalogoManualScreen extends StatelessWidget {
  const CatalogoManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Catálogo de Familias', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: catalogoFamilias.length, // Viene del archivo protocolo5_provider.dart
          itemBuilder: (context, index) {
            return _ConstruirTarjetaProducto(familia: catalogoFamilias[index]);
          },
        ),
      ),
    );
  }
}

// --- 3. WIDGET DE LA TARJETA DEL INSECTO ---
class _ConstruirTarjetaProducto extends StatelessWidget {
  final FamiliaMacroinvertebrado familia;
  const _ConstruirTarjetaProducto({required this.familia});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Protocolo5Provider>(context, listen: false);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(familia.imagenUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.bug_report, size: 50, color: Colors.grey)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(familia.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('Valor: ${familia.valor}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    provider.agregarFamilia(familia);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${familia.nombre} agregado'), duration: const Duration(milliseconds: 800)));
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 36),
                    backgroundColor: const Color(0xFFCCFF00).withOpacity(0.3),
                    elevation: 0,
                  ),
                  child: const Text('Añadir', style: TextStyle(color: Colors.black87)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 4. FUNCIÓN DEL CARRITO EMERGENTE ---
void _mostrarCarrito(BuildContext context, Protocolo5Provider provider) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Familias Seleccionadas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: Consumer<Protocolo5Provider>(
                builder: (context, prov, child) {
                  if (prov.carrito.isEmpty) return const Center(child: Text('El carrito está vacío'));
                  return ListView.builder(
                    itemCount: prov.carrito.length,
                    itemBuilder: (context, index) {
                      final item = prov.carrito[index];
                      return ListTile(
                        leading: const Icon(Icons.bug_report, color: Colors.green),
                        title: Text(item.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Valor BMWP: ${item.valor}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => prov.eliminarFamilia(item),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}