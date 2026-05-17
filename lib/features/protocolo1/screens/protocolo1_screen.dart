// Archivo: lib/features/protocolo1/screens/protocolo1_screen.dart

import 'package:flutter/material.dart';
import '../../../core/services/protocolo_service.dart';
import '../../../core/services/local_db_service.dart';

class Protocolo1Screen extends StatefulWidget {
  final String biomonitoreoId;

  const Protocolo1Screen({super.key, required this.biomonitoreoId});

  @override
  State<Protocolo1Screen> createState() => _Protocolo1ScreenState();
}

class _Protocolo1ScreenState extends State<Protocolo1Screen> {
  int _estadoProtocolo = 0;
  bool _isSubmitting = false;
  bool _isLoadingData = true;

  final _proyectoCtrl = TextEditingController();
  final _contactoCtrl = TextEditingController();
  final _provinciaCtrl = TextEditingController();
  final _objetivoCtrl = TextEditingController();
  final _tecnicosCtrl = TextEditingController();
  final _conductorCtrl = TextEditingController();
  final _fechaPlanCtrl = TextEditingController();

  // --- LISTA DINÁMICA DE ESTACIONES y TÉCNICOS ---
  List<Map<String, TextEditingController>> _estaciones = [];
  List<TextEditingController> _tecnicosCtrls = [];

  final Map<String, bool> _parametrosInSitu = {
    'Conductividad': false, 'pH': false, 'Temperatura': false,
    'Oxígeno disuelto': false, 'Salinidad': false, 'Turbiedad': false,
  };
  final Map<String, bool> _equipos = {
    'Flujómetro': false, 'Termómetro': false, 'Conductivímetro': false,
    'Multiparámetros': false, 'GPS': false, 'Cámara fotográfica': false,
  };
  final Map<String, bool> _documentacion = {
    'P-001. Plan de Muestreo': false, 'P-002. Caracterización Visual y Fisicoquímica': false,
    'P-003a. Caracterización de Hábitat (Alto)': false, 'P-003b. Caracterización de Hábitat (Bajo)': false,
    'P-004. Muestreo Multihábitat': false, 'P-005. Análisis de Muestras': false,
  };
  final Map<String, String> _insumos = {
    'Red tipo D': '', 'Envases plásticos': '', 'Caja de Herramienta': '', 'R. Triangular': '',
    'Frascos fisicoq.': '', 'Tijeras': '', 'Celular': '', 'Cinta métrica': '',
    'Bolsas herméticas': '', 'Lápices': '', 'C. fluorescentes': '', 'Tabla anot.': '',
    'Lupas': '', 'Viales de plásticos': '', 'Alcohol': '', 'Tamices': '',
    'Pilotos indelebles': '', 'C. adhesiva': '', 'Etiquetas': '', 'Pinzas entomol.': '',
    'Guantes': '', 'Bandejas blancas': '', 'Mascarillas': '', 'Botellas de lavado': '',
  };

  @override
  void initState() {
    super.initState();
    _tecnicosCtrls.add(TextEditingController());
    // Agregamos una estación vacía por defecto
    _agregarEstacion();
    _cargarBorrador();
  }

  void _agregarEstacion() {
    setState(() {
      _estaciones.add({
        'control': TextEditingController(),
        'lugar': TextEditingController(),
        'tipo_muestra': TextEditingController(),
        'fecha': TextEditingController(),
        'hora': TextEditingController(),
      });
    });
  }

  void _agregarTecnico() {
    setState(() {
      _tecnicosCtrls.add(TextEditingController());
    });
  }

  void _eliminarTecnico(int index) {
    if (_tecnicosCtrls.length > 1) {
      setState(() {
        _tecnicosCtrls[index].dispose();
        _tecnicosCtrls.removeAt(index);
      });
    }
  }

  void _eliminarEstacion(int index) {
    setState(() {
      _estaciones[index]['control']?.dispose();
      _estaciones[index]['lugar']?.dispose();
      _estaciones[index]['tipo_muestra']?.dispose();
      _estaciones[index]['fecha']?.dispose();
      _estaciones[index]['hora']?.dispose();
      _estaciones.removeAt(index);
    });
  }

  // Separamos la lógica de empaquetado para reusarla
  Map<String, dynamic> _prepararJSON() {
    return {
      "datos_generales": {
        "proyecto": _proyectoCtrl.text.trim(),
        "contacto": _contactoCtrl.text.trim(),
        "provincia": _provinciaCtrl.text.trim(),
        "objetivo": _objetivoCtrl.text.trim(),
      },
      "identificacion": {
        "estaciones": _estaciones.map((est) => {
          'control': est['control']!.text,
          'lugar': est['lugar']!.text,
          'tipo_muestra': est['tipo_muestra']!.text,
          'fecha': est['fecha']!.text,
          'hora': est['hora']!.text,
        }).toList(),
      },
      "responsables": {
        // Mapeamos la lista de controladores a una lista de Strings
        "tecnicos": _tecnicosCtrls.map((c) => c.text.trim()).toList(),
        "conductor": _conductorCtrl.text.trim(),
        "fecha_elaboracion_plan": _fechaPlanCtrl.text.trim(),
      },
      "parametros_in_situ": _parametrosInSitu,
      "verificacion_materiales": {
        "equipos": _equipos,
        "documentacion": _documentacion,
        "insumos": _insumos,
      }
    };
  }

  // --- CARGAR DATOS (OFFLINE FIRST) ---
  Future<void> _cargarBorrador() async {
    final localDB = LocalDBService();
    final cloudService = ProtocoloService();
    
    // 1. Buscamos primero en el teléfono
    Map<String, dynamic>? data = await localDB.obtenerBorradorLocal(widget.biomonitoreoId, 1);
    
    // 2. Si no hay nada en el teléfono, intentamos traer de Node.js
    if (data == null) {
      data = await cloudService.obtenerMiBorrador(widget.biomonitoreoId, 1);
      // Si Node.js sí nos mandó algo, lo guardamos localmente de una vez
      if (data != null && data['datos_formulario'] != null) {
        await localDB.guardarBorradorLocal(
          biomonitoreoId: widget.biomonitoreoId,
          protocoloNumero: 1,
          datosFormulario: data['datos_formulario'],
          sincronizado: 1, // Ya está en la nube
        );
      }
    }

    if (data != null && data['datos_formulario'] != null) {
      final form = data['datos_formulario'];
      setState(() {
        
        // Generales
        if (form['datos_generales'] != null) {
          _proyectoCtrl.text = form['datos_generales']['proyecto'] ?? '';
          _contactoCtrl.text = form['datos_generales']['contacto'] ?? '';
          _provinciaCtrl.text = form['datos_generales']['provincia'] ?? '';
          _objetivoCtrl.text = form['datos_generales']['objetivo'] ?? '';
        }

        // Responsables (Incluyendo la lista de Técnicos dinámicos)
        if (form['responsables'] != null) {
          _conductorCtrl.text = form['responsables']['conductor'] ?? '';
          _fechaPlanCtrl.text = form['responsables']['fecha_elaboracion_plan'] ?? '';
          
          if (form['responsables']['tecnicos'] != null) {
            List tecnicosGuardados = form['responsables']['tecnicos'];
            if (tecnicosGuardados.isNotEmpty) {
              _tecnicosCtrls.clear();
              for (var tec in tecnicosGuardados) {
                _tecnicosCtrls.add(TextEditingController(text: tec.toString()));
              }
            }
          }
        }
        
        // Estaciones (Dinámicas)
        if (form['identificacion'] != null && form['identificacion']['estaciones'] != null) {
          List estacionesGuardadas = form['identificacion']['estaciones'];
          if (estacionesGuardadas.isNotEmpty) {
            _estaciones.clear(); 
            for (var est in estacionesGuardadas) {
              _estaciones.add({
                'control': TextEditingController(text: est['control'] ?? ''),
                'lugar': TextEditingController(text: est['lugar'] ?? ''),
                'tipo_muestra': TextEditingController(text: est['tipo_muestra'] ?? ''),
                'fecha': TextEditingController(text: est['fecha'] ?? ''),
                'hora': TextEditingController(text: est['hora'] ?? ''),
              });
            }
          }
        }

        // Mapas booleanos y de texto
        if (form['parametros_in_situ'] != null) {
          form['parametros_in_situ'].forEach((k, v) => _parametrosInSitu[k] = v);
        }
        _estadoProtocolo = _parametrosInSitu.values.any((v) => v == true) ? 2 : 1;
        if (form['verificacion_materiales'] != null) {
          if (form['verificacion_materiales']['equipos'] != null) {
             form['verificacion_materiales']['equipos'].forEach((k, v) => _equipos[k] = v);
          }
          if (form['verificacion_materiales']['documentacion'] != null) {
             form['verificacion_materiales']['documentacion'].forEach((k, v) => _documentacion[k] = v);
          }
          if (form['verificacion_materiales']['insumos'] != null) {
             form['verificacion_materiales']['insumos'].forEach((k, v) => _insumos[k] = v.toString());
          }
        }
      });
    }
    setState(() => _isLoadingData = false);
  }

  // --- GUARDAR DATOS (OFFLINE FIRST) ---
  Future<bool> _guardarProtocolo() async {
    setState(() => _isSubmitting = true);

    Map<String, dynamic> datosCompletos = _prepararJSON(); // Usa la función que armamos en el paso anterior
    
    final localDB = LocalDBService();
    final cloudService = ProtocoloService();

    // Si hay al menos un true en los checkboxes In Situ, es 2. Si no, es 1.
    int estadoCalculado = _parametrosInSitu.values.any((v) => v == true) ? 2 : 1;
    setState(() => _estadoProtocolo = estadoCalculado);

    // 1. SIEMPRE guardamos local primero (Estado pendiente: 0)
    await localDB.guardarBorradorLocal(
      biomonitoreoId: widget.biomonitoreoId,
      protocoloNumero: 1,
      datosFormulario: datosCompletos,
      sincronizado: 0, 
    );

    // 2. Intentamos enviar a Node.js
    final exitoNube = await cloudService.sincronizarProtocolo(widget.biomonitoreoId, 1, datosCompletos);

    setState(() => _isSubmitting = false);

    if (exitoNube && mounted) {
      // 3. Si la nube dice "OK", actualizamos SQLite a sincronizado (1)
      await localDB.guardarBorradorLocal(
        biomonitoreoId: widget.biomonitoreoId,
        protocoloNumero: 1,
        datosFormulario: datosCompletos,
        sincronizado: 1, 
      );
      setState(() => _estadoProtocolo = 2);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado en el teléfono y sincronizado en la nube ☁️'), backgroundColor: Colors.green));
      return true;
    } else if (mounted) {
      // Si falla el internet, avisamos que se guardó local
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sin internet. Guardado localmente en el teléfono 📱'), backgroundColor: Colors.blueGrey));
      return true; // Retornamos true porque localmente SÍ se guardó
    }
    return false;
  }

  // --- REGLA NATIVA: CALENDARIOS Y RELOJES ---
  Future<void> _seleccionarFecha(TextEditingController controller) async {
    DateTime? seleccion = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (seleccion != null) {
      // Formato sencillo DD/MM/YYYY
      controller.text = "${seleccion.day.toString().padLeft(2,'0')}/${seleccion.month.toString().padLeft(2,'0')}/${seleccion.year}";
    }
  }

  Future<void> _seleccionarHora(TextEditingController controller) async {
    TimeOfDay? seleccion = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (seleccion != null && mounted) {
      controller.text = seleccion.format(context);
    }
  }

  // Flecha hacia atrás segura
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
      if (exito) Navigator.pop(context, _estadoProtocolo); // Sale de la pantalla y devuelve el estado actualizado
      return false; // Interceptamos el back original
    } else if (guardar == false) {
      Navigator.pop(context); // Sale directo sin guardar
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
                // Si el usuario da click en el botón inferior, guardamos y salimos
                if(ok && mounted) Navigator.pop(context, _estadoProtocolo);
              },
              icon: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(_estadoProtocolo == 2 ? Icons.check_circle : Icons.save_outlined),
              label: Text(_isSubmitting ? 'Guardando...' : 'Guardar y Salir', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ),

        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 180.0,
              elevation: 1,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _alPresionarAtras,
              ),
              title: const Text('Protocolo 1'),
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Plan de Monitoreo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Planificación de equipos y parámetros a medir en campo.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildBannerAdvertencia(context),

                  // SECCIÓN 1 Y 2
                  _buildSeccionExpandible(context: context, titulo: '1 y 2. Datos Generales', icono: Icons.business_center_outlined, contenido: [
                    _buildCampoTexto(context, 'Nombre del Proyecto', controlador: _proyectoCtrl),
                    _buildCampoTexto(context, 'Persona de contacto', controlador: _contactoCtrl),
                    _buildCampoTexto(context, 'Provincia o provincias', controlador: _provinciaCtrl),
                    const Divider(height: 32),
                    const Text('Objetivo del muestreo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _objetivoCtrl,
                      maxLines: 3, textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(filled: true, fillColor: Theme.of(context).colorScheme.surfaceContainerHighest, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    ),
                  ]),
                  const SizedBox(height: 12),

                  // SECCIÓN 3: ESTACIONES DINÁMICAS
                  _buildSeccionExpandible(context: context, titulo: '3. Identificación (Estaciones)', icono: Icons.pin_drop_outlined, contenido: [
                    for (int i = 0; i < _estaciones.length; i++) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Estación ${i + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                                if (_estaciones.length > 1) IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _eliminarEstacion(i)),
                              ],
                            ),
                            _buildCampoTexto(context, 'N° de Control', controlador: _estaciones[i]['control'], hint: 'Ej. EST-001'),
                            _buildCampoTexto(context, 'Lugar', controlador: _estaciones[i]['lugar']),
                            _buildCampoTexto(context, 'Tipo de muestra', controlador: _estaciones[i]['tipo_muestra']),
                            Row(
                              children: [
                                Expanded(child: _buildCampoTexto(context, 'Fecha', icono: Icons.calendar_today, controlador: _estaciones[i]['fecha'], esLectura: true, onTap: () => _seleccionarFecha(_estaciones[i]['fecha']!))),
                                const SizedBox(width: 12),
                                Expanded(child: _buildCampoTexto(context, 'Hora', icono: Icons.access_time, controlador: _estaciones[i]['hora'], esLectura: true, onTap: () => _seleccionarHora(_estaciones[i]['hora']!))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    OutlinedButton.icon(
                      onPressed: _agregarEstacion,
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: const Text('Agregar otra estación'),
                    )
                  ]),
                  const SizedBox(height: 12),

                  // SECCIÓN 4
                  _buildSeccionExpandible(context: context, titulo: '4. Parámetros a evaluar (In Situ)', icono: Icons.science_outlined, contenido: [
                    Wrap(spacing: 8.0, children: _parametrosInSitu.keys.map((k) => SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: _buildCheckboxSencillo(context, k, _parametrosInSitu))).toList()),
                  ]),
                  const SizedBox(height: 12),

                  // SECCIÓN 5: RESPONSABLES DINÁMICOS
                 _buildSeccionExpandible(
                    context: context, 
                    titulo: '5. Responsables', 
                    icono: Icons.groups_outlined, 
                    contenido: [
                      Text('Técnicos', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(height: 8),
                      for (int i = 0; i < _tecnicosCtrls.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(child: _buildCampoTexto(context, 'Nombre del Técnico', controlador: _tecnicosCtrls[i])),
                              if (_tecnicosCtrls.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                  onPressed: () => _eliminarTecnico(i),
                                ),
                            ],
                          ),
                        ),
                      TextButton.icon(
                        onPressed: _agregarTecnico,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar otro técnico'),
                      ),
                      const Divider(height: 32),
                      _buildCampoTexto(context, 'Conductor', controlador: _conductorCtrl),
                      _buildCampoTexto(
                        context, 
                        'Fecha de elaboración del plan', 
                        icono: Icons.calendar_today, 
                        controlador: _fechaPlanCtrl, 
                        esLectura: true, 
                        onTap: () => _seleccionarFecha(_fechaPlanCtrl)
                      ),
                    ]
                  ),
                  const SizedBox(height: 12),

                  // SECCIÓN 6
                  _buildSeccionExpandible(context: context, titulo: '6. Verificación de Materiales', icono: Icons.checklist_rtl_outlined, contenido: [
                    const Text('a) Equipos', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(spacing: 8.0, children: _equipos.keys.map((k) => SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: _buildCheckboxSencillo(context, k, _equipos))).toList()),
                    const Divider(height: 32),
                    const Text('b) Documentación', style: TextStyle(fontWeight: FontWeight.bold)),
                    ..._documentacion.keys.map((k) => _buildCheckboxSencillo(context, k, _documentacion)),
                    const Divider(height: 32),
                    const Text('c) Insumos', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(spacing: 16.0, runSpacing: 12.0, children: _insumos.keys.map((k) => SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: _buildInputInsumo(context, k))).toList()),
                  ]),

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
  
  Widget _buildCampoTexto(BuildContext context, String etiqueta, {TextEditingController? controlador, IconData? icono, bool esLectura = false, String? hint, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controlador,
        readOnly: esLectura,
        onTap: onTap,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: etiqueta, hintText: hint, filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          suffixIcon: icono != null ? Icon(icono, color: Colors.grey) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
        ),
      ),
    );
  }

  Widget _buildBannerAdvertencia(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_estadoProtocolo == 0) {
      // ESTADO ROJO: Faltan datos pre-campo
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
                '¡ACCIÓN REQUERIDA!\nDebes completar la planificación (Secciones 1, 2, 3, 5 y 6) con conexión a Internet antes de salir a la estación.',
                style: TextStyle(
                  fontSize: 13,
                  // Color fijo eliminado
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_estadoProtocolo == 1) {
      // ESTADO NARANJA: Falta In Situ
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? Colors.orange.shade800 : Colors.orange.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on_outlined, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Planificación completada. No olvides registrar los Parámetros In Situ (Sección 4) al llegar a la estación de muestreo.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // ESTADO VERDE: Todo completo
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.green.withOpacity(0.1) : Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? Colors.green.shade800 : Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green.shade700),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Protocolo 1 completado en su totalidad.',
                style: TextStyle(fontSize: 13), // Color fijo eliminado
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSeccionExpandible({required BuildContext context, required String titulo, required IconData icono, required List<Widget> contenido}) {
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)), child: Icon(icono)),
          title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          iconColor: Theme.of(context).colorScheme.primary,
          childrenPadding: const EdgeInsets.all(20), expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: contenido,
        ),
      ),
    );
  }

  Widget _buildCheckboxSencillo(BuildContext context, String titulo, Map<String, bool> mapa) {
    return CheckboxListTile(
      title: Text(titulo, style: const TextStyle(fontSize: 13)), value: mapa[titulo],
      activeColor: Theme.of(context).colorScheme.primary, controlAffinity: ListTileControlAffinity.leading, dense: true, contentPadding: EdgeInsets.zero,
      onChanged: (v) => setState(() => mapa[titulo] = v ?? false),
    );
  }

  Widget _buildInputInsumo(BuildContext context, String titulo) {
    // Al cargar el borrador, los insumos vienen como Strings, por eso asignamos .text si no está vacío
    final ctrl = TextEditingController(text: _insumos[titulo]);
    return Row(
      children: [
        Expanded(child: Text(titulo, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        SizedBox(width: 50, height: 35, child: TextFormField(
          controller: ctrl, keyboardType: TextInputType.number, textAlign: TextAlign.center,
          onChanged: (v) => _insumos[titulo] = v,
          decoration: InputDecoration(hintText: 'Ud.', filled: true, fillColor: Theme.of(context).colorScheme.surfaceContainerHighest, contentPadding: EdgeInsets.zero, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
        )),
      ],
    );
  }
}