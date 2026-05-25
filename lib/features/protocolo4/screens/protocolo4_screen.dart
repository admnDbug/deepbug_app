// Archivo: lib/features/protocolo4/screens/protocolo4_screen.dart

import 'package:flutter/material.dart';
import '../../../core/services/protocolo_service.dart';
import '../../../core/services/local_db_service.dart';

class Protocolo4Screen extends StatefulWidget {
  final String estacionId; // <-- NUEVO: RECIBIMOS EL ID DEL PROYECTO

  const Protocolo4Screen({super.key, required this.estacionId});

  @override
  State<Protocolo4Screen> createState() => _Protocolo4ScreenState();
}

class _Protocolo4ScreenState extends State<Protocolo4Screen> {
  bool _isSubmitting = false;
  bool _isLoadingData = true;

  // --- TRUCO SENIOR: Controladores Dinámicos para textos ---
  final Map<String, TextEditingController> _ctrls = {};

  TextEditingController _getCtrl(String key) {
    if (!_ctrls.containsKey(key)) {
      _ctrls[key] = TextEditingController();
    }
    return _ctrls[key]!;
  }

  // --- VARIABLES: 4. FAUNA ASOCIADA (0 a 4) ---
  final Map<String, int> _faunaAsociada = {
    'Perifiton': 0, 'Algas filament.': 0, 'Macrófitas': 0, 'Macroinvertebrados': 0, 'Peces': 0, 'Porífera': 0,
  };

  // --- VARIABLES: 5. ESTIMACIÓN PRELIMINAR (0 a 4) ---
  final Map<String, int> _estimacionPreliminar = {
    'Gasteropoda': 0, 'Bivalvia': 0, 'Turbellaria': 0, 'Oligochaeta': 0, 'Hirudinea': 0, 'Diptera': 0,
    'Amphipoda': 0, 'Isopoda': 0, 'Cangrejo': 0, 'Camarón': 0, 'Ephemeroptera': 0, 'Plecoptera': 0,
    'Odonata': 0, 'Hemiptera': 0, 'Megaloptera': 0, 'Trichoptera': 0, 'Lepidoptera': 0, 'Coleoptera': 0,
  };

  @override
  void initState() {
    super.initState();
    _cargarBorrador();
  }

  @override
  void dispose() {
    _ctrls.values.forEach((c) => c.dispose());
    super.dispose();
  }

  // --- CARGAR DATOS (SÓLO LOCAL - OFFLINE) ---
  Future<void> _cargarBorrador() async {
    final localDB = LocalDBService();
    
    // 1. SOLAMENTE buscamos el progreso guardado en el teléfono (SQLite)
    Map<String, dynamic>? data = await localDB.obtenerBorradorLocal(widget.estacionId, 4);
    
    // ELIMINADO: La llamada a cloudService.obtenerMiBorrador() se quitó por completo.
    // Con esto evitamos sobreescrituras en campo si la señal de internet es intermitente.

    if (data != null && data['datos_formulario'] != null) {
      final form = data['datos_formulario'];
      
      if (mounted) {
        setState(() {
          // Cargar textos dinámicos (porcentajes, arrastres, método, observaciones)
          if (form['textos'] != null) {
            form['textos'].forEach((key, value) {
              _getCtrl(key).text = value.toString();
            });
          }

          // Cargar mapas de fauna (0 a 4)
          if (form['fauna_asociada'] != null) {
            form['fauna_asociada'].forEach((k, v) => _faunaAsociada[k] = (v as num).toInt());
          }
          if (form['estimacion_preliminar'] != null) {
            form['estimacion_preliminar'].forEach((k, v) => _estimacionPreliminar[k] = (v as num).toInt());
          }
        });
      }
    }
    
    if (mounted) {
      setState(() => _isLoadingData = false);
    }
  }

  // --- PREPARAR JSON ---
  Map<String, dynamic> _prepararJSON() {
    Map<String, String> textos = {};
    _ctrls.forEach((key, controller) {
      textos[key] = controller.text.trim();
    });

    return {
      "textos": textos,
      "fauna_asociada": _faunaAsociada,
      "estimacion_preliminar": _estimacionPreliminar,
    };
  }

  // --- GUARDAR PROTOCOLO (OFFLINE FIRST) ---
  Future<bool> _guardarProtocolo() async {
    setState(() => _isSubmitting = true);
    Map<String, dynamic> datosCompletos = _prepararJSON(); 
    
    final localDB = LocalDBService();
    final cloudService = ProtocoloService();

    await localDB.guardarBorradorLocal(
      estacionId: widget.estacionId,
      protocoloNumero: 4,
      datosFormulario: datosCompletos,
      sincronizado: 0, 
    );

    final exitoNube = await cloudService.sincronizarProtocolo(widget.estacionId, 4, datosCompletos);
    setState(() => _isSubmitting = false);

    if (exitoNube && mounted) {
      await localDB.guardarBorradorLocal(
        estacionId: widget.estacionId, protocoloNumero: 4, datosFormulario: datosCompletos, sincronizado: 1, 
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado en el teléfono y sincronizado en la nube ☁️'), backgroundColor: Colors.green));
      return true;
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sin internet. Guardado localmente en el teléfono 📱'), backgroundColor: Colors.blueGrey));
      return true; 
    }
    return false;
  }

  // --- FLECHA HACIA ATRÁS ---
  Future<bool> _alPresionarAtras() async {
    bool? guardar = await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('¿Guardar cambios?'),
        content: const Text('¿Deseas guardar tu progreso en la nube antes de salir?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Salir sin guardar', style: TextStyle(color: Colors.red))),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Guardar y salir', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (guardar == true) {
      bool exito = await _guardarProtocolo();
      if (exito && mounted) Navigator.pop(context); 
      return false; 
    } else if (guardar == false) {
      Navigator.pop(context); 
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return WillPopScope(
      onWillPop: _alPresionarAtras,
      child: Scaffold(
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

        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 160.0,
              elevation: 1,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _alPresionarAtras,
              ),
              title: const Text('Protocolo 4', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Muestreo Multihábitat', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Porcentajes, arrastres y estimación de macroinvertebrados.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 3. TIPOS DE HÁBITAT
                  _buildSeccionExpandible(
                    context: context, titulo: 'Tipos de Hábitat', icono: Icons.pie_chart_outline,
                    contenido: [
                      Text('Determinación de los tipos y su porcentaje', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(height: 12),
                      _buildFilaPorcentaje(context, 'porcentaje_h1', 'Hábitat 1. Sustrato duro rápidos'),
                      _buildFilaPorcentaje(context, 'porcentaje_h2', 'Hábitat 2. Detrito Vegetal'),
                      _buildFilaPorcentaje(context, 'porcentaje_h3', 'Hábitat 3. Orillas vegetadas'),
                      _buildFilaPorcentaje(context, 'porcentaje_h4', 'Hábitat 4. Macrófitas acuáticas'),
                      _buildFilaPorcentaje(context, 'porcentaje_h5', 'Hábitat 5. Arena u otros sedimen.'),
                      _buildCampoTexto(context, 'otros_habitat', 'Otros (Especificar):'),

                      const Divider(height: 32),
                      Text('Cálculo del número de arrastres por tipo', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildFilaArrastre(context, 'arrastre_h1', 'H1')), const SizedBox(width: 16),
                          Expanded(child: _buildFilaArrastre(context, 'arrastre_h4', 'H4')),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildFilaArrastre(context, 'arrastre_h2', 'H2')), const SizedBox(width: 16),
                          Expanded(child: _buildFilaArrastre(context, 'arrastre_h5', 'H5')),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildFilaArrastre(context, 'arrastre_h3', 'H3')), const SizedBox(width: 16),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildCampoTexto(context, 'metodo_colecta', 'Método de colecta:'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4. FAUNA ASOCIADA
                  _buildSeccionExpandible(
                    context: context, titulo: 'Fauna Asociada', icono: Icons.pets_outlined,
                    contenido: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text('0 = Ausente\n1 = Rara (1-3 org.)\n2 = Común (3-9)\n3 = Abundante (>10 org.)\n4 = Dominante (>50 org.)', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
                      ),
                      const SizedBox(height: 16),
                      ..._faunaAsociada.keys.map((key) => _buildEscala0a4(context, key, _faunaAsociada[key]!, (val) => setState(() => _faunaAsociada[key] = val))),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 5. ESTIMACIÓN PRELIMINAR
                  _buildSeccionExpandible(
                    context: context, titulo: 'Estimación Preliminar (Campo)', icono: Icons.bug_report_outlined,
                    contenido: [
                      Text('Abundancia estimada de macroinvertebrados:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16.0, runSpacing: 8.0,
                        children: _estimacionPreliminar.keys.map((key) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width * 0.38,
                            child: _buildEscala0a4(context, key, _estimacionPreliminar[key]!, (val) => setState(() => _estimacionPreliminar[key] = val), modoCompacto: true),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 6. OBSERVACIONES
                  _buildSeccionExpandible(
                    context: context, titulo: 'Observaciones', icono: Icons.notes_outlined,
                    contenido: [
                      TextFormField(
                        controller: _getCtrl('observaciones'), // <-- Ahora sí se guarda en base de datos
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Escribe aquí cualquier comentario adicional...',
                          filled: true, fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildSeccionExpandible({required BuildContext context, required String titulo, required IconData icono, required List<Widget> contenido}) {
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)), child: Icon(icono)),
          title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          iconColor: Theme.of(context).colorScheme.primary, collapsedIconColor: Colors.grey, childrenPadding: const EdgeInsets.all(20), expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: contenido,
        ),
      ),
    );
  }

  Widget _buildCampoTexto(BuildContext context, String key, String etiqueta, {IconData? icono, bool esLectura = false, bool tecladoNumerico = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: _getCtrl(key),
        readOnly: esLectura,
        keyboardType: tecladoNumerico ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: etiqueta, filled: true, fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          suffixIcon: icono != null ? Icon(icono, color: Colors.grey) : null, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
        ),
      ),
    );
  }

  Widget _buildFilaPorcentaje(BuildContext context, String key, String etiqueta) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(etiqueta, style: const TextStyle(fontSize: 14))),
          SizedBox(
            width: 80, height: 40,
            child: TextFormField(
              controller: _getCtrl(key),
              keyboardType: TextInputType.number, textAlign: TextAlign.center,
              decoration: InputDecoration(
                suffixText: '%', filled: true, fillColor: Theme.of(context).colorScheme.surfaceContainerHighest, contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilaArrastre(BuildContext context, String key, String etiqueta) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextFormField(
                controller: _getCtrl(key),
                keyboardType: TextInputType.number, textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true, fillColor: Theme.of(context).colorScheme.surfaceContainerHighest, contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscala0a4(BuildContext context, String titulo, int valorActual, ValueChanged<int> onSelected, {bool modoCompacto = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: modoCompacto ? 12 : 14)), const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              bool isSelected = valorActual == index;
              return GestureDetector(
                onTap: () => onSelected(index),
                child: Container(
                  width: modoCompacto ? 24 : 35, height: modoCompacto ? 24 : 35, alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                    border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : (isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(index.toString(), style: TextStyle(color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: modoCompacto ? 12 : 14)),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}