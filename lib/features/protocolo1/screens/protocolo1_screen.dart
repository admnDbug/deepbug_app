// Archivo: lib/features/protocolo1/screens/protocolo1_screen.dart

import 'package:flutter/material.dart';
import '../../../core/services/protocolo_service.dart';
import '../../../core/services/local_db_service.dart';

class Protocolo1Screen extends StatefulWidget {
  final String estacionId;
  final String nombreEstacionInicial; 

  const Protocolo1Screen({
    super.key, 
    required this.estacionId,
    required this.nombreEstacionInicial,
  });

  @override
  State<Protocolo1Screen> createState() => _Protocolo1ScreenState();
}

class _Protocolo1ScreenState extends State<Protocolo1Screen> {
  int _estadoProtocolo = 0;
  bool _isSubmitting = false;
  bool _isLoadingData = true;

  final _contactoCtrl = TextEditingController();
  final _provinciaCtrl = TextEditingController();
  final _objetivoCtrl = TextEditingController();
  final _conductorCtrl = TextEditingController();
  final _fechaPlanCtrl = TextEditingController();

  List<TextEditingController> _tecnicosCtrls = [];

  bool _adecuacionEmb = false; bool _adecuacionEmbNo = false; final _causaAdecuacionCtrl = TextEditingController();
  bool _limpiezaEq = false; bool _limpiezaEqNo = false; final _causaLimpiezaCtrl = TextEditingController();
  bool _verifMetrologica = false; final _obsEquiposCtrl = TextEditingController();
  
  final List<String> _listaEquipos = ['Flujómetro', 'Termómetro', 'Conductivímetro', 'Multiparámetros', 'GPS', 'Cámara fotográfica'];
  late Map<String, Map<String, bool>> _equiposDetalle;

  final Map<String, TextEditingController> _insumosCtrls = {};
  final List<String> _nombresInsumosBase = [
    'Red tipo D', 'Envases plásticos', 'Caja de Herramienta', 'R. Triangular', 'Frascos fisicoq.', 'Tijeras', 
    'Celular', 'Cinta métrica', 'Bolsas herméticas', 'Lápices', 'C. fluorescentes', 'Tabla anot.', 
    'Lupas', 'Viales de plásticos', 'Alcohol', 'Tamices', 'Pilotos indelebles', 'C. adhesiva', 
    'Etiquetas', 'Pinzas entomol.', 'Guantes', 'Bandejas blancas', 'Mascarillas', 'Botellas de lavado'
  ];
  List<Map<String, TextEditingController>> _otrosInsumos = [];

  @override
  void initState() {
    super.initState();
    _tecnicosCtrls.add(TextEditingController());
    
    _equiposDetalle = { for (var e in _listaEquipos) e: {'llevar': false, 'patrones': false} };
    for (var ins in _nombresInsumosBase) { _insumosCtrls[ins] = TextEditingController(); }

    _cargarBorrador();
  }

  void _agregarTecnico() {
    setState(() { _tecnicosCtrls.add(TextEditingController()); });
  }

  void _eliminarTecnico(int index) {
    if (_tecnicosCtrls.length > 1) {
      setState(() {
        _tecnicosCtrls[index].dispose();
        _tecnicosCtrls.removeAt(index);
      });
    }
  }

  Map<String, dynamic> _prepararJSON() {
    Map<String, dynamic> equiposFormat = {
      'adecuacion': _adecuacionEmb, 'adecuacion_no': _adecuacionEmbNo, 'adecuacion_txt': _causaAdecuacionCtrl.text,
      'limpieza': _limpiezaEq, 'limpieza_no': _limpiezaEqNo, 'limpieza_txt': _causaLimpiezaCtrl.text,
      'metrologica': _verifMetrologica, 'observacion': _obsEquiposCtrl.text,
    };
    
    _equiposDetalle.forEach((eq, valores) {
      equiposFormat[eq] = valores['llevar'];
      if (eq != 'Cámara fotográfica') equiposFormat['Patron_$eq'] = valores['patrones'];
    });

    Map<String, String> insumosFormat = {};
    _insumosCtrls.forEach((k, v) => insumosFormat[k] = v.text);
    List<Map<String, String>> otrosInsumosFormat = _otrosInsumos.map((e) => {'nombre': e['nombre']!.text, 'cantidad': e['cantidad']!.text}).toList();

    return {
      "verificacion_materiales": {
        "equipos": equiposFormat,
        "insumos": insumosFormat,
        "otros_insumos": otrosInsumosFormat
      },
      "datos_generales": {
        "contacto": _contactoCtrl.text.trim(),
        "provincia": _provinciaCtrl.text.trim(),
        "objetivo": _objetivoCtrl.text.trim(),
      },
      "responsables": {
        "tecnicos": _tecnicosCtrls.map((c) => c.text.trim()).toList(),
        "conductor": _conductorCtrl.text.trim(),
        "fecha_elaboracion_plan": _fechaPlanCtrl.text.trim(),
      }
    };
  }

  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is Map) return _parseBool(value['valor'] ?? value['llevar'] ?? false);
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  String _parseStr(dynamic value) {
    if (value == null) return '';
    if (value is Map) return _parseStr(value['valor'] ?? value['texto'] ?? '');
    return value.toString();
  }

Future<void> _cargarBorrador() async {
    final localDB = LocalDBService();
    final cloudService = ProtocoloService();
    
    Map<String, dynamic>? data = await localDB.obtenerBorradorLocal(widget.estacionId, 1);
    if (data == null) {
      data = await cloudService.obtenerMiBorrador(widget.estacionId, 1);
      if (data != null && data['datos_formulario'] != null) {
        await localDB.guardarBorradorLocal(estacionId: widget.estacionId, protocoloNumero: 1, datosFormulario: data['datos_formulario'], sincronizado: 1);
      }
    }

    if (data == null || data['datos_formulario'] == null) {
      setState(() { _estadoProtocolo = 1; });
    } else {
      final form = data['datos_formulario'];
      setState(() {
        if (form['datos_generales'] != null) {
          _contactoCtrl.text = form['datos_generales']['contacto']?.toString() ?? '';
          _provinciaCtrl.text = form['datos_generales']['provincia']?.toString() ?? '';
          _objetivoCtrl.text = form['datos_generales']['objetivo']?.toString() ?? '';
        }

        if (form['responsables'] != null) {
          _conductorCtrl.text = form['responsables']['conductor']?.toString() ?? '';
          _fechaPlanCtrl.text = form['responsables']['fecha_elaboracion_plan']?.toString() ?? '';
          if (form['responsables']['tecnicos'] != null) {
            List tecnicosGuardados = form['responsables']['tecnicos'];
            if (tecnicosGuardados.isNotEmpty) {
              _tecnicosCtrls.clear();
              for (var tec in tecnicosGuardados) { _tecnicosCtrls.add(TextEditingController(text: tec?.toString() ?? '')); }
            }
          }
        }
        
        if (form['verificacion_materiales'] != null) {
          var mat = form['verificacion_materiales'];
          var eq = mat['equipos'] ?? {};
          if (eq is! Map) eq = {};

          _adecuacionEmb = _parseBool(eq['adecuacion']);
          _adecuacionEmbNo = _parseBool(eq['adecuacion_no']);
          _causaAdecuacionCtrl.text = _parseStr(eq['adecuacion_txt']);

          _limpiezaEq = _parseBool(eq['limpieza']);
          _limpiezaEqNo = _parseBool(eq['limpieza_no']);
          _causaLimpiezaCtrl.text = _parseStr(eq['limpieza_txt']);

          _verifMetrologica = _parseBool(eq['metrologica']);
          _obsEquiposCtrl.text = _parseStr(eq['observacion']);

          for (String k in _listaEquipos) {
            _equiposDetalle[k]!['llevar'] = _parseBool(eq[k]);
            if (k != 'Cámara fotográfica') {
              _equiposDetalle[k]!['patrones'] = _parseBool(eq['Patron_$k']);
            }
          }

          if (mat['insumos'] != null && mat['insumos'] is Map) {
             mat['insumos'].forEach((k, v) { if (_insumosCtrls.containsKey(k)) _insumosCtrls[k]!.text = _parseStr(v); });
          }
          if (mat['otros_insumos'] != null && mat['otros_insumos'] is Iterable) {
             _otrosInsumos.clear();
             for (var oi in mat['otros_insumos']) {
               if (oi is Map) {
                 _otrosInsumos.add({'nombre': TextEditingController(text: _parseStr(oi['nombre'])), 'cantidad': TextEditingController(text: _parseStr(oi['cantidad']))});
               }
             }
          }
        }
      });
    }
    setState(() => _isLoadingData = false);
  }

  Future<bool> _guardarProtocolo() async {
    setState(() => _isSubmitting = true);
    Map<String, dynamic> datosCompletos = _prepararJSON();
    
    final localDB = LocalDBService();
    final cloudService = ProtocoloService();

    await localDB.guardarBorradorLocal(
      estacionId: widget.estacionId,
      protocoloNumero: 1,
      datosFormulario: datosCompletos,
      sincronizado: 0, 
    );

    final exitoNube = await cloudService.sincronizarProtocolo(widget.estacionId, 1, datosCompletos);
    setState(() => _isSubmitting = false);

    if (exitoNube && mounted) {
      await localDB.guardarBorradorLocal(
        estacionId: widget.estacionId,
        protocoloNumero: 1,
        datosFormulario: datosCompletos,
        sincronizado: 1, 
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado en el teléfono y sincronizado en la nube ☁️'), backgroundColor: Colors.green));
      return true;
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sin internet. Guardado localmente en el teléfono 📱'), backgroundColor: Colors.blueGrey));
      return true;
    }
    return false;
  }

  Future<void> _seleccionarFecha(TextEditingController controller) async {
    DateTime? seleccion = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (seleccion != null) {
      controller.text = "${seleccion.day.toString().padLeft(2,'0')}/${seleccion.month.toString().padLeft(2,'0')}/${seleccion.year}";
    }
  }

  Future<void> _seleccionarHora(TextEditingController controller) async {
    TimeOfDay? seleccion = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (seleccion != null && mounted) { controller.text = seleccion.format(context); }
  }

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
      if (exito) Navigator.pop(context, _estadoProtocolo);
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
              leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: _alPresionarAtras),
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
                  _buildSeccionExpandible(context: context, titulo: 'Verificación de Materiales', icono: Icons.checklist_rtl_outlined, contenido: [
                    const Text('a) Equipos e instrumentos de medición', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                    const SizedBox(height: 12),
                    _buildCheckComplejoWeb('Verificar adecuación de los embalajes', _adecuacionEmb, _adecuacionEmbNo, _causaAdecuacionCtrl, (val){ setState(()=> _adecuacionEmb = val!);}, (val){ setState(()=> _adecuacionEmbNo = val!);}),
                    _buildCheckComplejoWeb('Limpieza de los equipos', _limpiezaEq, _limpiezaEqNo, _causaLimpiezaCtrl, (val){ setState(()=> _limpiezaEq = val!);}, (val){ setState(()=> _limpiezaEqNo = val!);}),
                    CheckboxListTile(title: const Text('Verificación metrológica de los instrumentos', style: TextStyle(fontWeight: FontWeight.bold)), value: _verifMetrologica, onChanged: (v)=> setState(()=> _verifMetrologica = v!), controlAffinity: ListTileControlAffinity.leading),
                    const SizedBox(height: 12),
                    Column(
                      children: _listaEquipos.map((eq) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade500), borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              CheckboxListTile(
                                dense: true, 
                                title: Text('Llevar $eq', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), 
                                value: _equiposDetalle[eq]!['llevar'], 
                                onChanged: (v)=> setState(()=> _equiposDetalle[eq]!['llevar'] = v!), 
                                controlAffinity: ListTileControlAffinity.leading
                              ),
                              if(eq != 'Cámara fotográfica') 
                                CheckboxListTile(
                                  dense: true, 
                                  title: const Text('Patrones de verificación', style: TextStyle(fontSize: 13, color: Colors.grey)), 
                                  value: _equiposDetalle[eq]!['patrones'], 
                                  onChanged: (v)=> setState(()=> _equiposDetalle[eq]!['patrones'] = v!), 
                                  controlAffinity: ListTileControlAffinity.leading
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(controller: _obsEquiposCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Observación equipos', border: OutlineInputBorder())),

                    const Divider(height: 32),
                    const Text('b) Insumos (Cantidades)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                    const SizedBox(height: 12),
                    Wrap(spacing: 16.0, runSpacing: 12.0, children: _nombresInsumosBase.map((k) => SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: Row(
                      children: [
                        Expanded(child: Text(k, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        SizedBox(width: 50, height: 35, child: TextFormField(controller: _insumosCtrls[k], keyboardType: TextInputType.number, textAlign: TextAlign.center, decoration: InputDecoration(filled: true, fillColor: Theme.of(context).colorScheme.surfaceContainerHighest, contentPadding: EdgeInsets.zero, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)))),
                      ],
                    ))).toList()),
    
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12), 
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest, 
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Otros Insumos', style: TextStyle(fontWeight: FontWeight.bold)),
                              OutlinedButton.icon(onPressed: () { setState(() { _otrosInsumos.add({'nombre': TextEditingController(), 'cantidad': TextEditingController()}); }); }, icon: const Icon(Icons.add, size: 16), label: const Text('Añadir'))
                            ],
                          ),
                          for(int i=0; i<_otrosInsumos.length; i++)
                            Padding(padding: const EdgeInsets.only(top: 8.0), child: Row(
                              children: [
                                Expanded(flex: 2, child: TextFormField(controller: _otrosInsumos[i]['nombre'], decoration: InputDecoration(hintText: 'Nombre insumo', isDense: true, filled: true, fillColor: Theme.of(context).colorScheme.surface))),
                                const SizedBox(width: 8),
                                Expanded(flex: 1, child: TextFormField(controller: _otrosInsumos[i]['cantidad'], keyboardType: TextInputType.number, textAlign: TextAlign.center, decoration: InputDecoration(hintText: 'Cant.', isDense: true, filled: true, fillColor: Theme.of(context).colorScheme.surface))),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () { setState(() { _otrosInsumos.removeAt(i); }); })
                              ],
                            ))
                        ]
                      )
                    ),
                  ]),
                  const SizedBox(height: 40),
                  _buildSeccionExpandible(context: context, titulo: 'Datos Generales', icono: Icons.business_center_outlined, contenido: [
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
                 _buildSeccionExpandible(context: context, titulo: 'Responsables', icono: Icons.groups_outlined, contenido: [
                      Text('Técnicos', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(height: 8),
                      for (int i = 0; i < _tecnicosCtrls.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(child: _buildCampoTexto(context, 'Nombre del Técnico', controlador: _tecnicosCtrls[i])),
                              if (_tecnicosCtrls.length > 1)
                                IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => _eliminarTecnico(i)),
                            ],
                          ),
                        ),
                      TextButton.icon(onPressed: _agregarTecnico, icon: const Icon(Icons.add), label: const Text('Agregar otro técnico')),
                      const Divider(height: 32),
                      _buildCampoTexto(context, 'Conductor', controlador: _conductorCtrl),
                      _buildCampoTexto(context, 'Fecha de elaboración del plan', icono: Icons.calendar_today, controlador: _fechaPlanCtrl, esLectura: true, onTap: () => _seleccionarFecha(_fechaPlanCtrl)),
                    ]
                  ),
                  const SizedBox(height: 12),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoTexto(BuildContext context, String etiqueta, {TextEditingController? controlador, IconData? icono, bool esLectura = false, String? hint, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controlador, readOnly: esLectura, onTap: onTap, textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: etiqueta, hintText: hint, filled: true, fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          suffixIcon: icono != null ? Icon(icono, color: Colors.grey) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
        ),
      ),
    );
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
  Widget _buildCheckComplejoWeb(String titulo, bool valCheck, bool valNo, TextEditingController ctrl, Function(bool?) onChangedCheck, Function(bool?) onChangedNo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            title: Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            value: valCheck, onChanged: onChangedCheck,
            controlAffinity: ListTileControlAffinity.leading, dense: true, contentPadding: EdgeInsets.zero
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: CheckboxListTile(
                  title: const Text('No', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  value: valNo, onChanged: onChangedNo,
                  controlAffinity: ListTileControlAffinity.leading, dense: true, contentPadding: EdgeInsets.zero
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: ctrl,
                  decoration: const InputDecoration(hintText: 'Especifique la causa...', isDense: true, border: OutlineInputBorder())
                )
              )
            ],
          ),
        ],
      ),
    );
  }
}