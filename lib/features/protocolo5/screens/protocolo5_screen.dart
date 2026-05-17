// Archivo: lib/features/protocolo5/screens/protocolo5_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/protocolo_service.dart';
import '../../../core/services/local_db_service.dart';
import '../providers/protocolo5_provider.dart';
import '../models/familia_macroinvertebrado.dart';
import '../../ia_scanner/screens/scanner_screen.dart'; // Ruta del scanner
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class Protocolo5Screen extends StatefulWidget {
  final String biomonitoreoId; // <-- NUEVO: RECIBIMOS EL ID DEL PROYECTO

  const Protocolo5Screen({super.key, required this.biomonitoreoId});

  @override
  State<Protocolo5Screen> createState() => _Protocolo5ScreenState();
}

class _Protocolo5ScreenState extends State<Protocolo5Screen> {
  bool _isSubmitting = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    // Usamos addPostFrameCallback para usar Provider de forma segura en initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarBorrador();
    });
  }

  // --- CARGAR DATOS (OFFLINE FIRST) ---
  Future<void> _cargarBorrador() async {
    final localDB = LocalDBService();
    final cloudService = ProtocoloService();
    final provider = Provider.of<Protocolo5Provider>(context, listen: false);
    
    Map<String, dynamic>? data = await localDB.obtenerBorradorLocal(widget.biomonitoreoId, 5);
    
    if (data == null) {
      data = await cloudService.obtenerMiBorrador(widget.biomonitoreoId, 5);
      if (data != null && data['datos_protocolo_5'] != null) {
        await localDB.guardarBorradorLocal(
          biomonitoreoId: widget.biomonitoreoId,
          protocoloNumero: 5,
          datosFormulario: data['datos_protocolo_5'], // Nota: Usamos otro campo si así lo definiste en Node
          sincronizado: 1, 
        );
      }
    }

    if (data != null) {
      // Busca en 'datos_formulario' o 'datos_protocolo_5' según tu backend
      final carritoGuardado = data['datos_formulario']?['carrito'] ?? data['datos_protocolo_5']?['carrito'];
      if (carritoGuardado != null) {
        provider.cargarDesdeBorrador(carritoGuardado);
      }
    }
    
    if (mounted) setState(() => _isLoadingData = false);
  }

  // --- GUARDAR PROTOCOLO (OFFLINE FIRST) ---
  Future<bool> _guardarProtocolo() async {
    setState(() => _isSubmitting = true);
    final provider = Provider.of<Protocolo5Provider>(context, listen: false);
    
    Map<String, dynamic> datosCompletos = {
      "carrito": provider.generarJsonParaGuardar(),
      "puntaje_bmwp_total": provider.puntajeTotal,
    }; 
    
    final localDB = LocalDBService();
    final cloudService = ProtocoloService();

    await localDB.guardarBorradorLocal(
      biomonitoreoId: widget.biomonitoreoId, protocoloNumero: 5, datosFormulario: datosCompletos, sincronizado: 0, 
    );

    final exitoNube = await cloudService.sincronizarProtocolo(widget.biomonitoreoId, 5, datosCompletos);
    setState(() => _isSubmitting = false);

    if (exitoNube && mounted) {
      await localDB.guardarBorradorLocal(
        biomonitoreoId: widget.biomonitoreoId, protocoloNumero: 5, datosFormulario: datosCompletos, sincronizado: 1, 
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado en la nube ☁️'), backgroundColor: Colors.green));
      return true;
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado localmente 📱'), backgroundColor: Colors.blueGrey));
      return true; 
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final provider = Provider.of<Protocolo5Provider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Protocolo 5', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      
      // --- NUEVO BOTÓN DE GUARDAR ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : () async {
              bool ok = await _guardarProtocolo();
              if(ok && mounted) Navigator.pop(context);
            },
            icon: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
            label: Text(_isSubmitting ? 'Guardando...' : 'Guardar Progreso', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
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
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Índice BMWP/Mex', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                        Text('Puntaje: ${provider.puntajeTotal}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _mostrarCarrito(context, provider),
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text('${provider.items.fold(0, (sum, item) => sum + item.cantidad)}'), // Suma todas las cantidades
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- NUEVO: RECORDATORIO DE FOTOS FALTANTES ---
              if (provider.faltanFotos)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade700, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade900),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Atención: Tienes familias sin evidencia fotográfica en el carrito.',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              const Text('¿Cómo deseas agregar las familias?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 20),

              _buildOpcionCard(
                titulo: 'Clasificar con IA', subtitulo: 'Usa la cámara para identificar el macroinvertebrado automáticamente.', icono: Icons.document_scanner_outlined,
                colorFondo: Theme.of(context).colorScheme.primaryContainer, colorTexto: Theme.of(context).colorScheme.onPrimaryContainer, colorIcono: Theme.of(context).colorScheme.primary, borde: false, sombra: true, isDark: isDark,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen())),
              ),

              const SizedBox(height: 16),

              _buildOpcionCard(
                titulo: 'Selección Manual', subtitulo: 'Explora el catálogo de familias y selecciona visualmente el espécimen.', icono: Icons.touch_app_outlined,
                colorFondo: Theme.of(context).colorScheme.surfaceContainerHighest, colorTexto: Theme.of(context).colorScheme.onSurface, colorIcono: Theme.of(context).colorScheme.primary, borde: true, sombra: false, isDark: isDark,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CatalogoManualScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpcionCard({required String titulo, required String subtitulo, required IconData icono, required Color colorFondo, required Color colorTexto, required Color colorIcono, required bool borde, required bool sombra, required bool isDark, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorFondo, borderRadius: BorderRadius.circular(16),
          border: borde ? Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300) : null,
          boxShadow: sombra ? [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          children: [
            Icon(icono, size: 40, color: colorIcono), const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorTexto)), const SizedBox(height: 4),
                  Text(subtitulo, style: TextStyle(fontSize: 13, color: colorTexto.withOpacity(0.8))),
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

// --- PANTALLA DEL CATÁLOGO ---
class CatalogoManualScreen extends StatelessWidget {
  const CatalogoManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Familias', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: catalogoFamilias.length, 
          itemBuilder: (context, index) {
            return _ConstruirTarjetaProducto(familia: catalogoFamilias[index]);
          },
        ),
      ),
    );
  }
}

class _ConstruirTarjetaProducto extends StatelessWidget {
  final FamiliaMacroinvertebrado familia;
  const _ConstruirTarjetaProducto({required this.familia});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Protocolo5Provider>(context);
    
    // --- VERIFICAMOS SI YA ESTÁ EN EL CARRITO ---
    final itemEnCarrito = provider.items.where((i) => i.familia.id == familia.id).firstOrNull;
    final int cantidadActual = itemEnCarrito?.cantidad ?? 0;
    final bool estaAgregado = cantidadActual > 0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Le ponemos un borde verde si ya está agregado
        side: BorderSide(color: estaAgregado ? Colors.green : Colors.transparent, width: 2)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(familia.imagenUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Icon(Icons.bug_report, size: 50, color: Theme.of(context).colorScheme.primary)),
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
                
                // --- BOTÓN DINÁMICO ---
                ElevatedButton(
                  onPressed: () {
                    provider.agregarFamilia(familia);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${familia.nombre} agregado'), duration: const Duration(milliseconds: 500)));
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 36),
                    backgroundColor: estaAgregado ? Colors.green.withOpacity(0.2) : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    foregroundColor: estaAgregado ? Colors.green.shade800 : Theme.of(context).colorScheme.onSurface,
                    elevation: 0,
                  ),
                  child: Text(estaAgregado ? 'Añadir más (Hay $cantidadActual)' : 'Añadir'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- FUNCIÓN DEL CARRITO EMERGENTE CON CANTIDADES Y FOTOS ---
void _mostrarCarrito(BuildContext context, Protocolo5Provider provider) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, 
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7, // Un poquito más alto
          child: Column(
            children: [
              const Text('Familias Seleccionadas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('Asegúrate de agregar foto a todas', style: TextStyle(color: Colors.orange, fontSize: 12)),
              const Divider(),
              Expanded(
                child: Consumer<Protocolo5Provider>(
                  builder: (context, prov, child) {
                    if (prov.estaVacio) return const Center(child: Text('El carrito está vacío'));
                    
                    return ListView.builder(
                      itemCount: prov.items.length,
                      itemBuilder: (context, index) {
                        final item = prov.items[index];
                        final faltaFoto = item.fotoBase64 == null;

                        return Card(
                          color: faltaFoto ? Colors.red.withOpacity(0.05) : null,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: faltaFoto ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                              // Si hay foto, mostramos una miniatura, si no, el contador
                              backgroundImage: !faltaFoto ? MemoryImage(base64Decode(item.fotoBase64!)) : null,
                              child: faltaFoto ? Text('${item.cantidad}x', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)) : null,
                            ),
                            title: Text(item.familia.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(faltaFoto ? 'Falta Evidencia' : 'Evidencia capturada', style: TextStyle(color: faltaFoto ? Colors.red : Colors.green, fontSize: 12)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // --- BOTÓN ACTUALIZADO PARA SELECCIONAR FUENTE ---
                                IconButton(
                                  icon: Icon(faltaFoto ? Icons.add_a_photo : Icons.published_with_changes, color: faltaFoto ? Colors.red : Colors.blue),
                                  onPressed: () => _seleccionarFuenteCarrito(context, prov, item.familia.id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => prov.reducirCantidad(item.familia.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// --- NUEVA FUNCIÓN AUXILIAR PARA EL CARRITO ---
void _seleccionarFuenteCarrito(BuildContext context, Protocolo5Provider prov, String familiaId) {
  showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      child: Wrap(
        children: [
          const ListTile(title: Text('Subir evidencia fotográfica', style: TextStyle(fontWeight: FontWeight.bold))),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Cámara'),
            onTap: () async {
              Navigator.pop(context); // Cierra el modal de selección
              final ImagePicker picker = ImagePicker();
              final XFile? foto = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
              if (foto != null) {
                final bytes = await foto.readAsBytes();
                prov.actualizarFoto(familiaId, base64Encode(bytes));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Galería'),
            onTap: () async {
              Navigator.pop(context); // Cierra el modal de selección
              final ImagePicker picker = ImagePicker();
              final XFile? foto = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
              if (foto != null) {
                final bytes = await foto.readAsBytes();
                prov.actualizarFoto(familiaId, base64Encode(bytes));
              }
            },
          ),
        ],
      ),
    ),
  );
}