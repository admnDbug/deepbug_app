// Archivo: lib/features/protocolo2/screens/protocolo2_screen.dart

import 'package:flutter/material.dart';
import '../../../core/services/protocolo_service.dart';
import '../../../core/services/local_db_service.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class Protocolo2Screen extends StatefulWidget {
  final String biomonitoreoId; // <-- 1. RECIBIMOS EL ID DEL PROYECTO

  const Protocolo2Screen({super.key, required this.biomonitoreoId});

  @override
  State<Protocolo2Screen> createState() => _Protocolo2ScreenState();
}

class _Protocolo2ScreenState extends State<Protocolo2Screen> {
  bool _isSubmitting = false;
  bool _isLoadingData = true;

  // --- TRUCO SENIOR: Generador dinámico de Controladores ---
  // En lugar de declarar 50 controladores a mano, este mapa los crea solos
  final Map<String, TextEditingController> _ctrls = {};

  TextEditingController _getCtrl(String key) {
    if (!_ctrls.containsKey(key)) {
      _ctrls[key] = TextEditingController();
    }
    return _ctrls[key]!;
  }

  // --- VARIABLES DE ESTADO (RadioButtons y Checkboxes) ---
  String _horarioSeleccionado = 'AM';
  String _lluviasPrevias = 'No';
  final Map<String, bool> _clima = {
    'Tormenta': false, 'Lluvia': false, 'Lluvia intermitente': false, 'Claro/Soleado': false, 'Nublado': false,
  };
  String _subsistemaRio = '';
  String _temperaturaAgua = '';
  String _tipologiaCurso = '';
  String? _fotoBase64;

  final Map<String, bool> _bosques = {'Bosque natural': false, 'Bosque plantado': false};
  final Map<String, bool> _estadoSucesional = {'Bosque maduro': false, 'Bosque secundario': false};
  final Map<String, bool> _cultivosPermanentes = {'Café': false, 'Plátano': false, 'Cítricos': false, 'Palmas': false};
  final Map<String, bool> _cultivosAnuales = {'Arroz': false, 'Caña': false, 'Maíz': false, 'Piña': false, 'Horticultura mixta': false};
  final Map<String, bool> _vegArbustiva = {'Rastrojos y arbustos': false, 'Formaciones herbáceas naturales': false, 'Vegetación baja inundable': false, 'Ganadería': false};
  final Map<String, bool> _otrosUsos = {'Área urbana': false, 'Área rural': false, 'Infraestructuras': false, 'Explo. minera': false, 'Acuicultura': false};

  final Map<String, bool> _descargas = {'Ninguna': false, 'Descarga directa': false, 'Descarga indirecta': false};
  final Map<String, bool> _tipoEfluente = {'Doméstica': false, 'Comercial': false, 'Industrial': false};
  
  String _residuosSolidos = '';
  String _rectificacion = '';
  String _canalizado = '';
  String _presenciaAceites = '';
  String _extracciones = '';
  String _presenciaPresas = '';
  String _erosionLocal = '';

  final Map<String, bool> _vegAcuatica = {'Enraizadas emergentes': false, 'Algas adheridas': false, 'Enraizadas sumergidas': false, 'Flotadoras libres': false, 'Ninguna': false};

  final Map<String, bool> _olorAgua = {'Ninguno': false, 'Pescado': false, 'Petróleo': false, 'Agua servida': false, 'Químico': false};
  final Map<String, bool> _colorAgua = {'Ninguno': false, 'Blanco': false, 'Gris': false, 'Verde': false, 'Marrón': false};
  String _coberturaDosel = '';

  @override
  void initState() {
    super.initState();
    _cargarBorrador();
  }

  @override
  void dispose() {
    // Limpiamos la memoria de todos los controladores
    _ctrls.values.forEach((c) => c.dispose());
    super.dispose();
  }

  // --- CARGAR DATOS (OFFLINE FIRST) ---
  Future<void> _cargarBorrador() async {
    final localDB = LocalDBService();
    final cloudService = ProtocoloService();
    
    Map<String, dynamic>? data = await localDB.obtenerBorradorLocal(widget.biomonitoreoId, 2);
    
    if (data == null) {
      data = await cloudService.obtenerMiBorrador(widget.biomonitoreoId, 2);
      if (data != null && data['datos_formulario'] != null) {
        await localDB.guardarBorradorLocal(
          biomonitoreoId: widget.biomonitoreoId,
          protocoloNumero: 2,
          datosFormulario: data['datos_formulario'],
          sincronizado: 1, 
        );
      }
    }

    if (data != null && data['datos_formulario'] != null) {
      final form = data['datos_formulario'];
      setState(() {
        // Cargar campos de texto dinámicos
        if (form['textos'] != null) {
          form['textos'].forEach((key, value) {
            _getCtrl(key).text = value.toString();
          });
        }
        // Cargar variables simples (Radios)
        _horarioSeleccionado = form['horario'] ?? 'AM';
        _lluviasPrevias = form['lluvias'] ?? 'No';
        _subsistemaRio = form['subsistema'] ?? '';
        _temperaturaAgua = form['temp_agua_radio'] ?? '';
        _tipologiaCurso = form['tipologia'] ?? '';
        _residuosSolidos = form['residuos'] ?? '';
        _rectificacion = form['rectificacion'] ?? '';
        _canalizado = form['canalizado'] ?? '';
        _presenciaAceites = form['aceites'] ?? '';
        _extracciones = form['extracciones'] ?? '';
        _presenciaPresas = form['presas'] ?? '';
        _erosionLocal = form['erosion'] ?? '';
        _coberturaDosel = form['dosel'] ?? '';
        _fotoBase64 = form['foto_base64'];

        // Cargar mapas (Checkboxes)
        if (form['clima'] != null) form['clima'].forEach((k, v) => _clima[k] = v);
        if (form['bosques'] != null) form['bosques'].forEach((k, v) => _bosques[k] = v);
        if (form['sucesional'] != null) form['sucesional'].forEach((k, v) => _estadoSucesional[k] = v);
        if (form['cult_perm'] != null) form['cult_perm'].forEach((k, v) => _cultivosPermanentes[k] = v);
        if (form['cult_anuales'] != null) form['cult_anuales'].forEach((k, v) => _cultivosAnuales[k] = v);
        if (form['veg_arbustiva'] != null) form['veg_arbustiva'].forEach((k, v) => _vegArbustiva[k] = v);
        if (form['otros_usos'] != null) form['otros_usos'].forEach((k, v) => _otrosUsos[k] = v);
        if (form['descargas'] != null) form['descargas'].forEach((k, v) => _descargas[k] = v);
        if (form['tipo_efluente'] != null) form['tipo_efluente'].forEach((k, v) => _tipoEfluente[k] = v);
        if (form['veg_acuatica'] != null) form['veg_acuatica'].forEach((k, v) => _vegAcuatica[k] = v);
        // Validamos que sea un mapa (datos nuevos) y no un String (datos viejos)
        if (form['olor'] != null && form['olor'] is Map) {
          form['olor'].forEach((k, v) => _olorAgua[k] = v);
        }
        if (form['color'] != null && form['color'] is Map) {
          form['color'].forEach((k, v) => _colorAgua[k] = v);
        }
      });
    }
    if (mounted) {
      setState(() => _isLoadingData = false);
    }
  }

  // --- PREPARAR JSON ---
  Map<String, dynamic> _prepararJSON() {
    // Extraemos todos los textos de nuestros controladores dinámicos
    Map<String, String> textos = {};
    _ctrls.forEach((key, controller) {
      textos[key] = controller.text.trim();
    });

    return {
      "textos": textos,
      "horario": _horarioSeleccionado,
      "lluvias": _lluviasPrevias,
      "subsistema": _subsistemaRio,
      "temp_agua_radio": _temperaturaAgua,
      "tipologia": _tipologiaCurso,
      "residuos": _residuosSolidos,
      "rectificacion": _rectificacion,
      "canalizado": _canalizado,
      "aceites": _presenciaAceites,
      "extracciones": _extracciones,
      "presas": _presenciaPresas,
      "erosion": _erosionLocal,
      "olor": _olorAgua,
      "color": _colorAgua,
      "dosel": _coberturaDosel,
      "clima": _clima,
      "bosques": _bosques,
      "sucesional": _estadoSucesional,
      "cult_perm": _cultivosPermanentes,
      "cult_anuales": _cultivosAnuales,
      "veg_arbustiva": _vegArbustiva,
      "otros_usos": _otrosUsos,
      "descargas": _descargas,
      "tipo_efluente": _tipoEfluente,
      "veg_acuatica": _vegAcuatica,
      "foto_base64": _fotoBase64,
    };
  }

  // --- 1. FUNCIÓN PARA ABRIR LA CÁMARA O GALERÍA ---
  Future<void> _capturarFoto(ImageSource fuente) async {
    final ImagePicker picker = ImagePicker();
    // imageQuality: 50 comprime la foto para no saturar SQLite
    final XFile? photo = await picker.pickImage(source: fuente, imageQuality: 50);

    if (photo != null) {
      final bytes = await photo.readAsBytes();
      setState(() {
        _fotoBase64 = base64Encode(bytes);
      });
    }
  }

  // --- 2. MODAL PARA ELEGIR LA FUENTE ---
  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Añadir fotografía', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tomar foto con la cámara'),
              onTap: () {
                Navigator.pop(context); // Cierra el menú
                _capturarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.pop(context); // Cierra el menú
                _capturarFoto(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16), // Espacio extra al final
          ],
        ),
      ),
    );
  }

  // --- GUARDAR PROTOCOLO (OFFLINE FIRST) ---
  Future<bool> _guardarProtocolo() async {
    setState(() => _isSubmitting = true);
    Map<String, dynamic> datosCompletos = _prepararJSON(); 
    
    final localDB = LocalDBService();
    final cloudService = ProtocoloService();

    await localDB.guardarBorradorLocal(
      biomonitoreoId: widget.biomonitoreoId,
      protocoloNumero: 2,
      datosFormulario: datosCompletos,
      sincronizado: 0, 
    );

    final exitoNube = await cloudService.sincronizarProtocolo(widget.biomonitoreoId, 2, datosCompletos);
    setState(() => _isSubmitting = false);

    if (exitoNube && mounted) {
      await localDB.guardarBorradorLocal(
        biomonitoreoId: widget.biomonitoreoId, protocoloNumero: 2, datosFormulario: datosCompletos, sincronizado: 1, 
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
      if (exito) Navigator.pop(context); 
      return false; 
    } else if (guardar == false) {
      Navigator.pop(context); 
      return false;
    }
    return false;
  }

  // --- SELECTORES NATIVOS ---
  Future<void> _seleccionarFecha(String key) async {
    DateTime? seleccion = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (seleccion != null) _getCtrl(key).text = "${seleccion.day.toString().padLeft(2,'0')}/${seleccion.month.toString().padLeft(2,'0')}/${seleccion.year}";
  }

  Future<void> _seleccionarHora(String key) async {
    TimeOfDay? seleccion = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (seleccion != null && mounted) _getCtrl(key).text = seleccion.format(context);
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
              label: Text(_isSubmitting ? 'Guardando...' : 'Guardar Progreso', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 220.0, // <-- CORRECCIÓN: Evita el pixel overflow
              elevation: 1,
              leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: _alPresionarAtras),
              title: const Text('Protocolo 2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Evaluación Visual del Hábitat', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Expande cada sección para llenar los datos.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1 y 2. DATOS GENERALES
                  _buildSeccionExpandible(
                    titulo: 'Datos Generales', icono: Icons.map_outlined,
                    contenido: [
                      _buildCampoTexto('n_control', 'Número de control'),
                      _buildCampoTexto('nombre_rio', 'Nombre del río'),
                      Row(
                        children: [
                          Expanded(child: _buildCampoTexto('id_estacion', 'ID Estación')), const SizedBox(width: 12),
                          Expanded(child: _buildCampoTexto('orden_rio', 'Orden del río', tecladoNumerico: true)),
                        ],
                      ),
                      _buildCampoTexto('cuenca', 'Cuenca'),
                      Row(
                        children: [
                          Expanded(child: _buildCampoTexto('latitud', 'Latitud', tecladoNumerico: true)), const SizedBox(width: 12),
                          Expanded(child: _buildCampoTexto('longitud', 'Longitud', tecladoNumerico: true)),
                        ],
                      ),
                      _buildCampoTexto('provincia', 'Provincia'),
                      Row(
                        children: [
                          Expanded(child: _buildCampoTexto('distrito', 'Distrito')), const SizedBox(width: 12),
                          Expanded(child: _buildCampoTexto('corregimiento', 'Corregimiento')),
                        ],
                      ),
                      _buildCampoTexto('localidad', 'Localidad'),
                      Row(
                        children: [
                          Expanded(child: _buildCampoTexto('proyecto', 'Proyecto')), const SizedBox(width: 12),
                          Expanded(child: _buildCampoTexto('altura', 'Altura (msnm)', tecladoNumerico: true)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildCampoTexto('fecha', 'Fecha', icono: Icons.calendar_today, esLectura: true, onTap: () => _seleccionarFecha('fecha'))), const SizedBox(width: 12),
                          Expanded(child: _buildCampoTexto('hora', 'Hora', icono: Icons.access_time, esLectura: true, onTap: () => _seleccionarHora('hora'))),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildRadioButton('AM', _horarioSeleccionado, (v) => setState(() => _horarioSeleccionado = v.toString())),
                          _buildRadioButton('PM', _horarioSeleccionado, (v) => setState(() => _horarioSeleccionado = v.toString())),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildCampoTexto('llenado_por', 'Llenado por', icono: Icons.person_outline),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 3. CONDICIONES CLIMÁTICAS
                  _buildSeccionExpandible(
                    titulo: 'Condiciones Climáticas', icono: Icons.cloud_outlined,
                    contenido: [
                      const Text('Selecciona las condiciones actuales:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ..._clima.keys.map((String key) => _buildCheckboxSencillo(key, _clima)),
                      const Divider(height: 24),
                      const Text('¿Lluvias en últimos 7 días?', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          _buildRadioButton('Sí', _lluviasPrevias, (v) => setState(() => _lluviasPrevias = v.toString())), const SizedBox(width: 16),
                          _buildRadioButton('No', _lluviasPrevias, (v) => setState(() => _lluviasPrevias = v.toString())),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildCampoTexto('nubosidad', 'Cobertura de nubosidad (%)', tecladoNumerico: true),
                      _buildCampoTexto('temp_amb', 'Temperatura Ambiental (°C)', tecladoNumerico: true),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4. LOCALIZACIÓN Y FOTO
                  _buildSeccionExpandible(
                    titulo: 'Localización y Fotografía', icono: Icons.camera_alt_outlined,
                    contenido: [
                      Text('Adjunta una fotografía de la estación de muestreo.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      // --- CONTENEDOR INTERACTIVO ---
                      GestureDetector(
                        onTap: _mostrarOpcionesImagen,
                        child: Container(
                          height: 200, // Lo hicimos de 200 para que la foto se vea mejor
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            // Si ya hay foto, la ponemos de fondo tapando todo el contenedor
                            image: _fotoBase64 != null
                                ? DecorationImage(
                                    image: MemoryImage(base64Decode(_fotoBase64!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          // Si NO hay foto, mostramos el icono y texto. Si SÍ hay foto, mostramos un botoncito flotante para editarla.
                          child: _fotoBase64 == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 40, color: Theme.of(context).colorScheme.primary), 
                                    const SizedBox(height: 8),
                                    Text('Toca para tomar foto', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                  ],
                                )
                              : Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      child: IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.white),
                                        onPressed: _mostrarOpcionesImagen,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      // -----------------------------------
                      const SizedBox(height: 16),
                      _buildCampoTexto('codigo_foto', 'Código de fotografía'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 5. CUERPO DE AGUA
                  _buildSeccionExpandible(
                    titulo: 'Características del Cuerpo de Agua', icono: Icons.water_outlined,
                    contenido: [
                      const Text('Subsistema del río', style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildRadioButton('Perenne', _subsistemaRio, (v) => setState(() => _subsistemaRio = v.toString())),
                      _buildRadioButton('Intermitente', _subsistemaRio, (v) => setState(() => _subsistemaRio = v.toString())),
                      _buildRadioButton('Estacional', _subsistemaRio, (v) => setState(() => _subsistemaRio = v.toString())),
                      const Divider(height: 24),
                      const Text('Temperatura del agua', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Expanded(child: _buildRadioButton('Agua fría', _temperaturaAgua, (v) => setState(() => _temperaturaAgua = v.toString()))),
                          Expanded(child: _buildRadioButton('Agua tibia', _temperaturaAgua, (v) => setState(() => _temperaturaAgua = v.toString()))),
                        ],
                      ),
                      const Divider(height: 24),
                      const Text('Tipología del curso de agua', style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildRadioButton('Parte Alta', _tipologiaCurso, (v) => setState(() => _tipologiaCurso = v.toString())),
                      _buildRadioButton('Parte Media', _tipologiaCurso, (v) => setState(() => _tipologiaCurso = v.toString())),
                      _buildRadioButton('Parte Baja', _tipologiaCurso, (v) => setState(() => _tipologiaCurso = v.toString())),
                      const SizedBox(height: 12),
                      _buildCampoTexto('area_cuenca', 'Área de la cuenca (Kms)', tecladoNumerico: true),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 6. COBERTURA BOSCOSA
                  _buildSeccionExpandible(
                    titulo: 'Cobertura Boscosa y Uso de Tierra', icono: Icons.nature_outlined,
                    contenido: [
                      Text('Bosques y Sucesión', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                      _buildCheckboxGroup(_bosques), _buildCheckboxGroup(_estadoSucesional),
                      const Divider(height: 24),
                      Text('Cultivos', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                      Text('Permanentes:', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      _buildCheckboxGroup(_cultivosPermanentes), _buildCampoTexto('otros_perm', 'Otros permanentes:'),
                      Text('Anuales:', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      _buildCheckboxGroup(_cultivosAnuales), _buildCampoTexto('otros_anuales', 'Otros anuales:'),
                      const Divider(height: 24),
                      Text('Vegetación y Otros Usos', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                      _buildCheckboxGroup(_vegArbustiva), _buildCheckboxGroup(_otrosUsos), _buildCampoTexto('otros_usos_texto', 'Otros usos:'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 7. DESCARGAS
                  _buildSeccionExpandible(
                    titulo: 'Descargas y Modificaciones', icono: Icons.delete_outline,
                    contenido: [
                      const Text('Descargas de efluentes', style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildCheckboxGroup(_descargas), const SizedBox(height: 12),
                      const Text('Tipo de efluentes', style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildCheckboxGroup(_tipoEfluente), const Divider(height: 24),
                      const Text('Modificaciones al cuerpo de agua (Sí / No)', style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildFilaSiNo('Residuos sólidos', _residuosSolidos, (v) => setState(() => _residuosSolidos = v.toString())),
                      _buildFilaSiNo('Rectificación', _rectificacion, (v) => setState(() => _rectificacion = v.toString())),
                      _buildFilaSiNo('Canalizado', _canalizado, (v) => setState(() => _canalizado = v.toString())),
                      _buildFilaSiNo('Presencia de aceites', _presenciaAceites, (v) => setState(() => _presenciaAceites = v.toString())),
                      _buildFilaSiNo('Extracciones', _extracciones, (v) => setState(() => _extracciones = v.toString())),
                      _buildFilaSiNo('Presencia de presas', _presenciaPresas, (v) => setState(() => _presenciaPresas = v.toString())),
                      const Divider(height: 24),
                      const Text('Erosión local', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Expanded(child: _buildRadioButton('Ninguna', _erosionLocal, (v) => setState(() => _erosionLocal = v.toString()))),
                          Expanded(child: _buildRadioButton('Moderada', _erosionLocal, (v) => setState(() => _erosionLocal = v.toString()))),
                          Expanded(child: _buildRadioButton('Severa', _erosionLocal, (v) => setState(() => _erosionLocal = v.toString()))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 8. VEGETACIÓN ACUÁTICA
                  _buildSeccionExpandible(
                    titulo: 'Vegetación Acuática', icono: Icons.grass_outlined,
                    contenido: [
                      const Text('Identifique la dominancia:', style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildCheckboxGroup(_vegAcuatica), const SizedBox(height: 16),
                      _buildCampoTexto('esp_dominantes', 'Presencia de especies dominantes:'),
                      _buildCampoTexto('porcentaje_veg', '% de cober. veg. acuática:', tecladoNumerico: true),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 9. CALIDAD DEL AGUA
                  _buildSeccionExpandible(
                    titulo: 'Calidad del Agua', icono: Icons.science_outlined,
                    contenido: [
                      Row(
                        children: [
                          Expanded(child: _buildCampoTexto('ca_temp', 'Temp. (C°)', tecladoNumerico: true)), const SizedBox(width: 8),
                          Expanded(child: _buildCampoTexto('ca_tds', 'TDS', tecladoNumerico: true)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildCampoTexto('ca_od', 'Oxíg. disuelto', tecladoNumerico: true)), const SizedBox(width: 8),
                          Expanded(child: _buildCampoTexto('ca_nitrito', 'Nitrito', tecladoNumerico: true)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildCampoTexto('ca_turb', 'Turbiedad', tecladoNumerico: true)), const SizedBox(width: 8),
                          Expanded(child: _buildCampoTexto('ca_nitrato', 'Nitrato', tecladoNumerico: true)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildCampoTexto('ca_ph', 'pH', tecladoNumerico: true)), const SizedBox(width: 8),
                          Expanded(child: _buildCampoTexto('ca_salinidad', 'Salinidad', tecladoNumerico: true)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildCampoTexto('ca_cond', 'Conductividad', tecladoNumerico: true)), const SizedBox(width: 8),
                          Expanded(child: _buildCampoTexto('ca_fosfatos', 'Fosfatos', tecladoNumerico: true)),
                        ],
                      ),
                      _buildCampoTexto('ca_equipos', 'Equipos utilizados:'),
                      const Divider(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Olores', style: TextStyle(fontWeight: FontWeight.bold)),
                                ..._olorAgua.keys.map((String key) => _buildCheckboxSencillo(key, _olorAgua)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
                                ..._colorAgua.keys.map((String key) => _buildCheckboxSencillo(key, _colorAgua)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 10. MEDICIONES
                  _buildSeccionExpandible(
                    titulo: ' Mediciones (Cuerpo de Agua)', icono: Icons.straighten_outlined,
                    contenido: [
                      _buildMatrizMediciones('ancho', 'Ancho (m)'), const Divider(height: 32),
                      _buildMatrizMediciones('prof', 'Profundidad (m)'), const Divider(height: 32),
                      _buildMatrizMediciones('vel', 'Velocidad (m/s)'), const Divider(height: 32),
                      const Text('Cobertura del dosel', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Expanded(child: _buildRadioButton('Abierta', _coberturaDosel, (v) => setState(() => _coberturaDosel = v.toString()))),
                          Expanded(child: _buildRadioButton('Cubierta', _coberturaDosel, (v) => setState(() => _coberturaDosel = v.toString()))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Tipo de morfología (%)', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildCampoTexto('morf_rapidos', 'Rápidos %', tecladoNumerico: true)), const SizedBox(width: 16),
                          Expanded(child: _buildCampoTexto('morf_pozas', 'Pozas %', tecladoNumerico: true)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 80), 
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSeccionExpandible({required String titulo, required IconData icono, required List<Widget> contenido}) {
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

  Widget _buildCampoTexto(String key, String etiqueta, {IconData? icono, bool esLectura = false, bool tecladoNumerico = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: _getCtrl(key), // <-- TRUCO APLICADO
        readOnly: esLectura,
        onTap: onTap,
        keyboardType: tecladoNumerico ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: etiqueta, filled: true, fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          suffixIcon: icono != null ? Icon(icono, color: Colors.grey) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
        ),
      ),
    );
  }

  Widget _buildRadioButton(String titulo, String valorGrupo, ValueChanged<String?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(value: titulo, groupValue: valorGrupo, activeColor: Theme.of(context).colorScheme.primary, visualDensity: const VisualDensity(horizontal: -4, vertical: -4), onChanged: onChanged),
        Flexible(child: Text(titulo, style: const TextStyle(fontSize: 14), overflow: TextOverflow.clip)),
      ],
    );
  }

  Widget _buildFilaSiNo(String pregunta, String valorActual, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(pregunta, style: const TextStyle(fontSize: 14))),
          Row(children: [_buildRadioButton('Sí', valorActual, onChanged), const SizedBox(width: 8), _buildRadioButton('No', valorActual, onChanged)]),
        ],
      ),
    );
  }

  Widget _buildCheckboxSencillo(String titulo, Map<String, bool> mapa) {
    return CheckboxListTile(
      title: Text(titulo, style: const TextStyle(fontSize: 14)), value: mapa[titulo], activeColor: Theme.of(context).colorScheme.primary, contentPadding: EdgeInsets.zero, dense: true,
      onChanged: (bool? value) => setState(() => mapa[titulo] = value ?? false),
    );
  }

  Widget _buildCheckboxGroup(Map<String, bool> opciones) {
    return Wrap(
      spacing: 8.0, runSpacing: 0.0,
      children: opciones.keys.map((String key) => SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: _buildCheckboxSencillo(key, opciones))).toList(),
    );
  }

  Widget _buildMatrizMediciones(String keyPrefijo, String titulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _buildFilaMatriz(keyPrefijo, 'm0', 'M0'),
        _buildFilaMatriz(keyPrefijo, 'm50', 'M50'),
        _buildFilaMatriz(keyPrefijo, 'm100', 'M100'),
      ],
    );
  }

  Widget _buildFilaMatriz(String keyPrefijo, String metroId, String etiquetaMetro) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 45, child: Text(etiquetaMetro, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))),
          Expanded(child: _buildCampoPequeno('${keyPrefijo}_${metroId}_p1', 'P1')), const SizedBox(width: 8),
          Expanded(child: _buildCampoPequeno('${keyPrefijo}_${metroId}_p2', 'P2')), const SizedBox(width: 8),
          Expanded(child: _buildCampoPequeno('${keyPrefijo}_${metroId}_p3', 'P3')),
        ],
      ),
    );
  }

  Widget _buildCampoPequeno(String key, String hint) {
    return SizedBox(
      height: 40,
      child: TextFormField(
        controller: _getCtrl(key), // <-- TRUCO APLICADO EN LA MATRIZ
        keyboardType: TextInputType.number, textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hint, hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
          filled: true, fillColor: Theme.of(context).colorScheme.surfaceContainerHighest, contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
        ),
      ),
    );
  }
}