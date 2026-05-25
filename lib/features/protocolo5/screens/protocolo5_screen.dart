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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class Protocolo5Screen extends StatefulWidget {
  final String estacionId; // <-- RECIBIMOS EL ID DEL PROYECTO

  const Protocolo5Screen({super.key, required this.estacionId});

  @override
  State<Protocolo5Screen> createState() => _Protocolo5ScreenState();
}

class _Protocolo5ScreenState extends State<Protocolo5Screen> {
  bool _isSubmitting = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarBorrador();
    });
  }

  // --- CARGAR DATOS CON DESCARGA AUTOMÁTICA DE IMÁGENES COMPRIMIDAS OFFLINE ---
  Future<void> _cargarBorrador() async {
    final localDB = LocalDBService();
    final provider = Provider.of<Protocolo5Provider>(context, listen: false);
    const String baseUrl = "https://deepbug-backend-staging.onrender.com/api";

    // 1. MODO ONLINE: Descarga desde el Estacion + compresión en segundo plano
    try {
      final prefs = await SharedPreferences.getInstance();
      final token =
          prefs.getString('token') ?? prefs.getString('auth_token') ?? '';

      // 🕵️‍♂️ Apuntamos al estacion para jalar su zona e índice personalizado
      final urlEstacion = Uri.parse('$baseUrl/estaciones/${widget.estacionId}');

      final response = await http.get(
        urlEstacion,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> estacionData = jsonDecode(response.body);

        // Extraemos de forma segura el catálogo de familias asociado a la cuenca
        List dataCatalogo = [];
        if (estacionData['zona_id'] != null &&
            estacionData['zona_id']['catalogo_familias'] != null) {
          dataCatalogo = estacionData['zona_id']['catalogo_familias'];
        }

        List<Map<String, dynamic>> catalogoModificadoConFotos = [];

        for (var f in dataCatalogo) {
          Map<String, dynamic> familiaMap = Map<String, dynamic>.from(f);
          String urlOriginal = f['imagen_url']?.toString() ?? '';

          // 🕵️‍♂️ HACK CLOUDINARY: Si es una URL válida, pedimos miniatura ultra-ligera
          if (urlOriginal.contains('/upload/')) {
            String urlComprimida = urlOriginal.replaceAll(
              '/upload/',
              '/upload/w_250,h_250,c_scale,q_50/',
            );
            try {
              // Descargamos los pocos kilobytes
              final resImg = await http
                  .get(Uri.parse(urlComprimida))
                  .timeout(const Duration(seconds: 3));
              if (resImg.statusCode == 200) {
                // La guardamos convertida en texto plano
                familiaMap['imagen_base64'] = base64Encode(resImg.bodyBytes);
              }
            } catch (_) {
              // Si falla, continúa sin romper el flujo
            }
          }
          catalogoModificadoConFotos.add(familiaMap);
        }

        // 🔥 RESPALDO OFFLINE COMPLETO: Guardamos JSON con fotos incrustadas y puntajes reales
        await prefs.setString(
          'catalogo_cache_${widget.estacionId}',
          jsonEncode(catalogoModificadoConFotos),
        );

        List<FamiliaMacroinvertebrado>
        familiasBd = catalogoModificadoConFotos.map((f) {
          return FamiliaMacroinvertebrado(
            id:
                f['_id']?.toString() ??
                f['id']?.toString() ??
                f['familia_id']?.toString() ??
                '',
            nombre: f['nombre_familia']?.toString() ?? 'Sin nombre',
            // 📊 Toma el valor dinámico guardado en la cuenca (fallback a 0.0)
            valor:
                double.tryParse(
                  f['valor_bmwp']?.toString() ??
                      f['valor']?.toString() ??
                      '0.0',
                ) ??
                0.0,
            imagenUrl: f['imagen_url']?.toString() ?? '',
            imagenBase64: f['imagen_base64']
                ?.toString(), // En memoria listo para usarse
          );
        }).toList();

        provider.actualizarCatalogo(familiasBd);
      }
    } catch (e) {
      debugPrint(
        "Modo Offline: Extrayendo catálogo e imágenes de zona desde SharedPreferences...",
      );

      final prefs = await SharedPreferences.getInstance();
      final String? catalogoGuardado = prefs.getString(
        'catalogo_cache_${widget.estacionId}',
      );

      if (catalogoGuardado != null) {
        List dataCatalogo = jsonDecode(catalogoGuardado);
        List<FamiliaMacroinvertebrado> familiasBd = dataCatalogo.map((f) {
          return FamiliaMacroinvertebrado(
            id:
                f['_id']?.toString() ??
                f['id']?.toString() ??
                f['familia_id']?.toString() ??
                '',
            nombre: f['nombre_familia']?.toString() ?? 'Sin nombre',
            valor:
                double.tryParse(
                  f['valor_bmwp']?.toString() ??
                      f['valor']?.toString() ??
                      '0.0',
                ) ??
                0.0,
            imagenUrl: f['imagen_url']?.toString() ?? '',
            imagenBase64: f['imagen_base64']
                ?.toString(), // Recuperado sin internet
          );
        }).toList();

        provider.actualizarCatalogo(familiasBd);
      }
    }

    // 2. Extraemos el progreso local de la muestra (SQLite)
    try {
      Map<String, dynamic>? data = await localDB.obtenerBorradorLocal(
        widget.estacionId,
        5,
      );
      if (data != null && data['datos_formulario'] != null) {
        final form = data['datos_formulario'];
        List? fams = form['datos_protocolo_5']?['familias_encontradas'];

        if (fams != null) {
          List<Map<String, dynamic>> famsMapeadas = fams.map((f) {
            String? fotoLimpia = f['foto_base64']?.toString();
            if (fotoLimpia != null && fotoLimpia.contains(',')) {
              fotoLimpia = fotoLimpia.split(',').last;
            }
            return {
              'familia_id': f['familia_id'] ?? f['id_familia'],
              'nombre_familia': f['nombre_familia'] ?? f['nombre'],
              'valor_bmwp': f['valor_bmwp'] ?? f['valor'],
              'cantidad': f['cantidad'] ?? 1,
              'foto_base64': fotoLimpia,
              'imagen_url': f['imagen_url'],
            };
          }).toList();
          provider.cargarDatosDesdeAlmacenamiento(famsMapeadas);
        } else {
          provider.clearSelectedFamilies();
        }
      } else {
        provider.clearSelectedFamilies();
      }
    } catch (e) {
      provider.clearSelectedFamilies();
    }

    if (mounted) setState(() => _isLoadingData = false);
  }

  // --- GUARDAR PROTOCOLO 5 (FORMATO EXACTO PARA LA WEB ORIGINAL) ---
  Future<bool> _guardarProtocolo() async {
    setState(() => _isSubmitting = true);
    final provider = Provider.of<Protocolo5Provider>(context, listen: false);

    Map<String, dynamic> datos_protocolo_5 = {
      "familias_encontradas": provider.items.map((item) {
        String? fotoCloudinary;
        if (item.fotoBase64 != null) {
          fotoCloudinary = item.fotoBase64!.startsWith('data:image')
              ? item.fotoBase64
              : 'data:image/jpeg;base64,${item.fotoBase64}';
        }
        return {
          "familia_id": item.familia.id,
          "nombre_familia": item.familia.nombre,
          "valor_bmwp": item.familia.valor,
          "cantidad": item.cantidad,
          "imagen_url": null,
          "foto_base64": fotoCloudinary,
        };
      }).toList(),
      "sumatoria_total_bmwp": provider.puntajeTotal,
    };

    final localDB = LocalDBService();
    final cloudService = ProtocoloService();

    await localDB.guardarBorradorLocal(
      estacionId: widget.estacionId,
      protocoloNumero: 5,
      datosFormulario: {"datos_protocolo_5": datos_protocolo_5},
      sincronizado: 0,
    );

    final exitoNube = await cloudService.sincronizarProtocolo(
      widget.estacionId,
      5,
      null,
      datosProtocolo5: datos_protocolo_5,
    );
    setState(() => _isSubmitting = false);

    if (exitoNube && mounted) {
      await localDB.guardarBorradorLocal(
        estacionId: widget.estacionId,
        protocoloNumero: 5,
        datosFormulario: {"datos_protocolo_5": datos_protocolo_5},
        sincronizado: 1,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '¡Análisis de IA sincronizado en la nube exitosamente! ☁️',
          ),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guardado localmente en el teléfono (Modo Offline) 📱'),
          backgroundColor: Colors.blueGrey,
        ),
      );
      return true;
    }
    return false;
  }

  // --- EVALUACIÓN DE CALIDAD DE AGUA (BMWP-RBTC) ---
  Map<String, dynamic> _obtenerCalidadAgua(double puntaje) {
    if (puntaje > 68) {
      return {
        'etiqueta': 'Excelente: Aguas no contaminadas',
        'color': Colors.blue.shade700,
      };
    } else if (puntaje > 52) {
      return {
        'etiqueta': 'Muy buena: Aguas no alteradas',
        'color': Colors.lightBlue,
      };
    } else if (puntaje > 39) {
      return {'etiqueta': 'Buena: Mod. contaminadas', 'color': Colors.green};
    } else if (puntaje > 26) {
      return {
        'etiqueta': 'Regular: Aguas contaminadas',
        'color': Colors.yellow.shade800,
      }; // shade800 para mejor lectura
    } else if (puntaje > 13) {
      return {
        'etiqueta': 'Mala: Aguas muy contaminadas',
        'color': Colors.orange,
      };
    } else {
      return {'etiqueta': 'Pésima: Ext. contaminadas', 'color': Colors.red};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final provider = Provider.of<Protocolo5Provider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Protocolo 5',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _isSubmitting
                ? null
                : () async {
                    bool ok = await _guardarProtocolo();
                    if (ok && mounted) Navigator.pop(context);
                  },
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              _isSubmitting ? 'Guardando...' : 'Guardar Progreso',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final calidad = _obtenerCalidadAgua(
                            provider.puntajeTotal,
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Índice BMWP-RBTC',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Puntaje: ${provider.puntajeTotal}',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: calidad['color'],
                                ),
                              ),
                              Text(
                                calidad['etiqueta'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: calidad['color'],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _mostrarCarrito(context, provider),
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text(
                        '${provider.items.fold(0, (sum, item) => sum + item.cantidad)}',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (provider.faltanFotos)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade700, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade900,
                      ),
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
              const Text(
                '¿Cómo deseas agregar las familias?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildOpcionCard(
                titulo: 'Clasificar con IA',
                subtitulo:
                    'Usa la cámara para identificar el macroinvertebrado automáticamente.',
                icono: Icons.document_scanner_outlined,
                colorFondo: Theme.of(context).colorScheme.primaryContainer,
                colorTexto: Theme.of(context).colorScheme.onPrimaryContainer,
                colorIcono: Theme.of(context).colorScheme.primary,
                borde: false,
                sombra: true,
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScannerScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildOpcionCard(
                titulo: 'Selección Manual',
                subtitulo:
                    'Explora el catálogo de familias y selecciona visualmente el espécimen.',
                icono: Icons.touch_app_outlined,
                colorFondo: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                colorTexto: Theme.of(context).colorScheme.onSurface,
                colorIcono: Theme.of(context).colorScheme.primary,
                borde: true,
                sombra: false,
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CatalogoManualScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpcionCard({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Color colorFondo,
    required Color colorTexto,
    required Color colorIcono,
    required bool borde,
    required bool sombra,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(16),
          border: borde
              ? Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                )
              : null,
          boxShadow: sombra
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icono, size: 40, color: colorIcono),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorTexto,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorTexto.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: colorTexto.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
} // <--- LLAVE DE CIERRE CLAVE DE LA CLASE STATE: Aquí terminaba el error

// --- PANTALLA DEL CATÁLOGO MANUAl (CON BUSCADOR INTEGRADO) ---
class CatalogoManualScreen extends StatefulWidget {
  const CatalogoManualScreen({super.key});

  @override
  State<CatalogoManualScreen> createState() => _CatalogoManualScreenState();
}

class _CatalogoManualScreenState extends State<CatalogoManualScreen> {
  String _terminoBusqueda = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Protocolo5Provider>(context);

    // Filtrar el catálogo según lo que el usuario escriba
    final catalogoFiltrado = provider.catalogo.where((familia) {
      return familia.nombre.toLowerCase().contains(
        _terminoBusqueda.toLowerCase(),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catálogo de Familias',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: provider.catalogo.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // --- BARRA DE BÚSQUEDA ---
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (valor) {
                        setState(() {
                          _terminoBusqueda = valor;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre de familia...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  // --- GRILLA DE RESULTADOS ---
                  Expanded(
                    child: catalogoFiltrado.isEmpty
                        ? const Center(
                            child: Text(
                              'No se encontraron familias con ese nombre.',
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: catalogoFiltrado.length,
                            itemBuilder: (context, index) {
                              return _ConstruirTarjetaProducto(
                                familia: catalogoFiltrado[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

// --- TARJETA DEL CATÁLOGO ADAPTATIVA (ONLINE / OFFLINE) ---
class _ConstruirTarjetaProducto extends StatelessWidget {
  final FamiliaMacroinvertebrado familia;
  const _ConstruirTarjetaProducto({required this.familia});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Protocolo5Provider>(context);
    final itemEnCarrito = provider.items
        .where((i) => i.familia.id == familia.id)
        .firstOrNull;
    final int cantidadActual = itemEnCarrito?.cantidad ?? 0;
    final bool estaAgregado = cantidadActual > 0;

    // 🕵️‍♂️ Validamos si tenemos la miniatura offline disponible
    final bool tieneFotoOffline =
        familia.imagenBase64 != null && familia.imagenBase64!.isNotEmpty;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: estaAgregado ? Colors.green : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: tieneFotoOffline
                  ? Image.memory(
                      base64Decode(familia.imagenBase64!),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.bug_report,
                        size: 50,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : Image.network(
                      familia.imagenUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.bug_report,
                        size: 50,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  familia.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Valor: ${familia.valor}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    provider.agregarFamilia(familia);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${familia.nombre} agregado'),
                        duration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 36),
                    backgroundColor: estaAgregado
                        ? Colors.green.withOpacity(0.2)
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                    foregroundColor: estaAgregado
                        ? Colors.green.shade800
                        : Theme.of(context).colorScheme.onSurface,
                    elevation: 0,
                  ),
                  child: Text(
                    estaAgregado
                        ? 'Añadir más (Hay $cantidadActual)'
                        : 'Añadir',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- FUNCIÓN DEL CARRITO EMERGENTE CON CANTIDADES CORREGIDAS ---
void _mostrarCarrito(BuildContext context, Protocolo5Provider provider) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              const Text(
                'Familias Seleccionadas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Asegúrate de agregar foto a todas',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
              const Divider(),
              Expanded(
                child: Consumer<Protocolo5Provider>(
                  builder: (context, prov, child) {
                    if (prov.estaVacio)
                      return const Center(child: Text('El carrito está vacío'));

                    return ListView.builder(
                      itemCount: prov.items.length,
                      itemBuilder: (context, index) {
                        final item = prov.items[index];
                        final faltaFoto = item.fotoBase64 == null;

                        return Card(
                          color: faltaFoto
                              ? Colors.red.withOpacity(0.05)
                              : null,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: faltaFoto
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.green.withOpacity(0.2),
                              backgroundImage: !faltaFoto
                                  ? MemoryImage(base64Decode(item.fotoBase64!))
                                  : null,
                              child: faltaFoto
                                  ? const Icon(
                                      Icons.bug_report,
                                      color: Colors.red,
                                    )
                                  : null,
                            ),
                            // CORRECCIÓN VISUAL: Mostramos la cantidad directamente al lado del nombre
                            title: Text(
                              '${item.familia.nombre} (x${item.cantidad})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              faltaFoto
                                  ? 'Falta Evidencia'
                                  : 'Evidencia capturada',
                              style: TextStyle(
                                color: faltaFoto ? Colors.red : Colors.green,
                                fontSize: 12,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    faltaFoto
                                        ? Icons.add_a_photo
                                        : Icons.published_with_changes,
                                    color: faltaFoto ? Colors.red : Colors.blue,
                                  ),
                                  onPressed: () => _seleccionarFuenteCarrito(
                                    context,
                                    prov,
                                    item.familia.id,
                                  ),
                                ),
                                // NUEVO BOTÓN: Para incrementar cantidad directo desde el carrito
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.green,
                                  ),
                                  onPressed: () =>
                                      prov.agregarFamilia(item.familia),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      prov.reducirCantidad(item.familia.id),
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

// --- SELECCIONAR FUENTE CON COMPRESIÓN RESPONSIVA EN RED ---
void _seleccionarFuenteCarrito(
  BuildContext context,
  Protocolo5Provider prov,
  String familiaId,
) {
  showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      child: Wrap(
        children: [
          const ListTile(
            title: Text(
              'Subir evidencia fotográfica',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Cámara'),
            onTap: () async {
              Navigator.pop(context);
              final ImagePicker picker = ImagePicker();
              // CORRECCIÓN RED: maxWidth y maxHeight reducen el String Base64 para que el backend lo acepte
              final XFile? foto = await picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 50,
                maxWidth: 800,
                maxHeight: 800,
              );
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
              Navigator.pop(context);
              final ImagePicker picker = ImagePicker();
              final XFile? foto = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 50,
                maxWidth: 800,
                maxHeight: 800,
              );
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
