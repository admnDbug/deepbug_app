// Archivo: lib/features/protocolo2/screens/protocolo2_screen.dart

import 'package:flutter/material.dart';

class Protocolo2Screen extends StatefulWidget {
  const Protocolo2Screen({super.key});

  @override
  State<Protocolo2Screen> createState() => _Protocolo2ScreenState();
}

class _Protocolo2ScreenState extends State<Protocolo2Screen> {
  // --- VARIABLES DE ESTADO ---
  
  String _horarioSeleccionado = 'AM';
  String _lluviasPrevias = 'No';
  final Map<String, bool> _clima = {'Tormenta': false, 'Lluvia': false, 'Lluvia intermitente': false, 'Claro/Soleado': false, 'Nublado': false};
  String _subsistemaRio = ''; String _temperaturaAgua = ''; String _tipologiaCurso = '';

  // --- VARIABLES: SECCIÓN 6 ---
  final Map<String, bool> _bosques = {'Bosque natural': false, 'Bosque plantado': false};
  final Map<String, bool> _estadoSucesional = {'Bosque maduro': false, 'Bosque secundario': false};
  final Map<String, bool> _cultivosPermanentes = {'Café': false, 'Plátano': false, 'Cítricos': false, 'Palmas': false};
  final Map<String, bool> _cultivosAnuales = {'Arroz': false, 'Caña': false, 'Maíz': false, 'Piña': false, 'Horticultura mixta': false};
  final Map<String, bool> _vegArbustiva = {'Rastrojos y arbustos': false, 'Formaciones herbáceas naturales': false, 'Vegetación baja inundable': false, 'Ganadería': false};
  final Map<String, bool> _otrosUsos = {'Área urbana': false, 'Área rural': false, 'Infraestructuras': false, 'Explo. minera': false, 'Acuicultura': false};

  // --- VARIABLES: SECCIÓN 7 ---
  final Map<String, bool> _descargas = {'Ninguna': false, 'Descarga directa': false, 'Descarga indirecta': false};
  final Map<String, bool> _tipoEfluente = {'Doméstica': false, 'Comercial': false, 'Industrial': false};
  String _residuosSolidos = ''; String _rectificacion = ''; String _canalizado = '';
  String _presenciaAceites = ''; String _extracciones = ''; String _presenciaPresas = '';
  String _erosionLocal = '';

  // --- VARIABLES: SECCIÓN 8 ---
  final Map<String, bool> _vegAcuatica = {'Enraizadas emergentes': false, 'Algas adheridas': false, 'Enraizadas sumergidas': false, 'Flotadoras libres': false, 'Ninguna': false};

  // --- VARIABLES: SECCIÓN 9 ---
  String _olorAgua = ''; String _colorAgua = '';

  // --- VARIABLES: SECCIÓN 10 ---
  String _coberturaDosel = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Borrador guardado exitosamente'))),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar Progreso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCCFF00), foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // CABECERA
          SliverAppBar(
            pinned: true, expandedHeight: 160.0, backgroundColor: Colors.white, surfaceTintColor: Colors.white, elevation: 1,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black87), onPressed: () => Navigator.pop(context)),
            title: const Text('Protocolo 2', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 20), color: Colors.white,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Evaluación Visual del Hábitat', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                    SizedBox(height: 8),
                    Text('Expande cada sección para llenar los datos.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          
          // LISTA DE ACORDEONES
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                
                // 1 y 2. DATOS GENERALES
                _buildSeccionExpandible(titulo: '1 y 2. Datos Generales', icono: Icons.map_outlined, contenido: [
                  _buildCampoTexto('Número de control'), _buildCampoTexto('Nombre del río'),
                  Row(children: [Expanded(child: _buildCampoTexto('ID Estación')), const SizedBox(width: 12), Expanded(child: _buildCampoTexto('Orden del río', tecladoNumerico: true))]),
                  _buildCampoTexto('Cuenca'),
                  Row(children: [Expanded(child: _buildCampoTexto('Latitud', tecladoNumerico: true)), const SizedBox(width: 12), Expanded(child: _buildCampoTexto('Longitud', tecladoNumerico: true))]),
                  _buildCampoTexto('Provincia'),
                  Row(children: [Expanded(child: _buildCampoTexto('Distrito')), const SizedBox(width: 12), Expanded(child: _buildCampoTexto('Corregimiento'))]),
                  _buildCampoTexto('Localidad'),
                  Row(children: [Expanded(child: _buildCampoTexto('Proyecto')), const SizedBox(width: 12), Expanded(child: _buildCampoTexto('Altura (msnm)', tecladoNumerico: true))]),
                  Row(children: [Expanded(child: _buildCampoTexto('Fecha', icono: Icons.calendar_today, esLectura: true)), const SizedBox(width: 12), Expanded(child: _buildCampoTexto('Hora', icono: Icons.access_time, esLectura: true))]),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    _buildRadioButton('AM', _horarioSeleccionado, (valor) => setState(() => _horarioSeleccionado = valor.toString())),
                    _buildRadioButton('PM', _horarioSeleccionado, (valor) => setState(() => _horarioSeleccionado = valor.toString())),
                  ]),
                  const SizedBox(height: 8), _buildCampoTexto('Llenado por', icono: Icons.person_outline),
                ]), const SizedBox(height: 12),

                // 3. CONDICIONES CLIMÁTICAS
                _buildSeccionExpandible(titulo: '3. Condiciones Climáticas', icono: Icons.cloud_outlined, contenido: [
                  const Text('Selecciona las condiciones actuales:', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8),
                  ..._clima.keys.map((String key) => _buildCheckboxSencillo(key, _clima)),
                  const Divider(height: 24), const Text('¿Lluvias en últimos 7 días?', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(children: [_buildRadioButton('Sí', _lluviasPrevias, (valor) => setState(() => _lluviasPrevias = valor.toString())), const SizedBox(width: 16), _buildRadioButton('No', _lluviasPrevias, (valor) => setState(() => _lluviasPrevias = valor.toString()))]),
                  const SizedBox(height: 12), _buildCampoTexto('Cobertura de nubosidad (%)', tecladoNumerico: true), _buildCampoTexto('Temperatura Ambiental (°C)', tecladoNumerico: true),
                ]), const SizedBox(height: 12),

                // 4. LOCALIZACIÓN
                _buildSeccionExpandible(titulo: '4. Localización y Fotografía', icono: Icons.camera_alt_outlined, contenido: [
                  const Text('Adjunta una fotografía de la estación de muestreo.', style: TextStyle(color: Colors.grey)), const SizedBox(height: 12),
                  Container(height: 150, decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40, color: Colors.grey), SizedBox(height: 8), Text('Toca para agregar foto', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))])),
                  const SizedBox(height: 16), _buildCampoTexto('Código de fotografía'),
                ]), const SizedBox(height: 12),

                // 5. CUERPO DE AGUA
                _buildSeccionExpandible(titulo: '5. Características del Cuerpo de Agua', icono: Icons.water_outlined, contenido: [
                  const Text('Subsistema del río', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildRadioButton('Perenne', _subsistemaRio, (v) => setState(() => _subsistemaRio = v.toString())), _buildRadioButton('Intermitente', _subsistemaRio, (v) => setState(() => _subsistemaRio = v.toString())), _buildRadioButton('Estacional', _subsistemaRio, (v) => setState(() => _subsistemaRio = v.toString())),
                  const Divider(height: 24), const Text('Temperatura del agua', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(children: [Expanded(child: _buildRadioButton('Agua fría', _temperaturaAgua, (v) => setState(() => _temperaturaAgua = v.toString()))), Expanded(child: _buildRadioButton('Agua tibia', _temperaturaAgua, (v) => setState(() => _temperaturaAgua = v.toString())))]),
                  const Divider(height: 24), const Text('Tipología del curso de agua', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildRadioButton('Parte Alta', _tipologiaCurso, (v) => setState(() => _tipologiaCurso = v.toString())), _buildRadioButton('Parte Media', _tipologiaCurso, (v) => setState(() => _tipologiaCurso = v.toString())), _buildRadioButton('Parte Baja', _tipologiaCurso, (v) => setState(() => _tipologiaCurso = v.toString())),
                  const SizedBox(height: 12), _buildCampoTexto('Área de la cuenca (Kms)', tecladoNumerico: true),
                ]), const SizedBox(height: 12),

                // --- 6. COBERTURA BOSCOSA ---
                _buildSeccionExpandible(titulo: '6. Cobertura Boscosa y Uso de Tierra', icono: Icons.nature_outlined, contenido: [
                  const Text('Bosques y Sucesión', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  _buildCheckboxGroup(_bosques), _buildCheckboxGroup(_estadoSucesional),
                  const Divider(height: 24), const Text('Cultivos', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  const Text('Permanentes:', style: TextStyle(fontSize: 12, color: Colors.grey)), _buildCheckboxGroup(_cultivosPermanentes), _buildCampoTexto('Otros permanentes:'),
                  const Text('Anuales:', style: TextStyle(fontSize: 12, color: Colors.grey)), _buildCheckboxGroup(_cultivosAnuales), _buildCampoTexto('Otros anuales:'),
                  const Divider(height: 24), const Text('Vegetación y Otros Usos', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  _buildCheckboxGroup(_vegArbustiva), _buildCheckboxGroup(_otrosUsos), _buildCampoTexto('Otros usos:'),
                ]), const SizedBox(height: 12),

                // --- 7. DESCARGAS Y MODIFICACIONES ---
                _buildSeccionExpandible(titulo: '7. Descargas y Modificaciones', icono: Icons.delete_outline, contenido: [
                  const Text('Descargas de efluentes', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildCheckboxGroup(_descargas),
                  const SizedBox(height: 12), const Text('Tipo de efluentes', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildCheckboxGroup(_tipoEfluente),
                  const Divider(height: 24), const Text('Modificaciones al cuerpo de agua (Sí / No)', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildFilaSiNo('Residuos sólidos', _residuosSolidos, (v) => setState(() => _residuosSolidos = v.toString())),
                  _buildFilaSiNo('Rectificación', _rectificacion, (v) => setState(() => _rectificacion = v.toString())),
                  _buildFilaSiNo('Canalizado', _canalizado, (v) => setState(() => _canalizado = v.toString())),
                  _buildFilaSiNo('Presencia de aceites', _presenciaAceites, (v) => setState(() => _presenciaAceites = v.toString())),
                  _buildFilaSiNo('Extracciones', _extracciones, (v) => setState(() => _extracciones = v.toString())),
                  _buildFilaSiNo('Presencia de presas', _presenciaPresas, (v) => setState(() => _presenciaPresas = v.toString())),
                  const Divider(height: 24), const Text('Erosión local', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(children: [
                    Expanded(child: _buildRadioButton('Ninguna', _erosionLocal, (v) => setState(() => _erosionLocal = v.toString()))),
                    Expanded(child: _buildRadioButton('Moderada', _erosionLocal, (v) => setState(() => _erosionLocal = v.toString()))),
                    Expanded(child: _buildRadioButton('Severa', _erosionLocal, (v) => setState(() => _erosionLocal = v.toString()))),
                  ])
                ]), const SizedBox(height: 12),

                // --- 8. VEGETACIÓN ACUÁTICA ---
                _buildSeccionExpandible(titulo: '8. Vegetación Acuática', icono: Icons.grass_outlined, contenido: [
                  const Text('Identifique la dominancia:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildCheckboxGroup(_vegAcuatica),
                  const SizedBox(height: 16),
                  _buildCampoTexto('Presencia de especies dominantes:'),
                  _buildCampoTexto('% de cober. veg. acuática:', tecladoNumerico: true),
                ]), const SizedBox(height: 12),

                // --- 9. CALIDAD DEL AGUA ---
                _buildSeccionExpandible(titulo: '9. Calidad del Agua', icono: Icons.science_outlined, contenido: [
                  Row(children: [Expanded(child: _buildCampoTexto('Temp. (C°)', tecladoNumerico: true)), const SizedBox(width: 8), Expanded(child: _buildCampoTexto('TDS', tecladoNumerico: true))]),
                  Row(children: [Expanded(child: _buildCampoTexto('Oxíg. disuelto', tecladoNumerico: true)), const SizedBox(width: 8), Expanded(child: _buildCampoTexto('Nitrito', tecladoNumerico: true))]),
                  Row(children: [Expanded(child: _buildCampoTexto('Turbiedad', tecladoNumerico: true)), const SizedBox(width: 8), Expanded(child: _buildCampoTexto('Nitrato', tecladoNumerico: true))]),
                  Row(children: [Expanded(child: _buildCampoTexto('pH', tecladoNumerico: true)), const SizedBox(width: 8), Expanded(child: _buildCampoTexto('Salinidad', tecladoNumerico: true))]),
                  Row(children: [Expanded(child: _buildCampoTexto('Conductividad', tecladoNumerico: true)), const SizedBox(width: 8), Expanded(child: _buildCampoTexto('Fosfatos', tecladoNumerico: true))]),
                  _buildCampoTexto('Equipos utilizados:'),
                  const Divider(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Olores', style: TextStyle(fontWeight: FontWeight.bold)),
                        _buildRadioButton('Ninguno', _olorAgua, (v) => setState(() => _olorAgua = v.toString())), _buildRadioButton('Pescado', _olorAgua, (v) => setState(() => _olorAgua = v.toString())), _buildRadioButton('Petróleo', _olorAgua, (v) => setState(() => _olorAgua = v.toString())), _buildRadioButton('Agua servida', _olorAgua, (v) => setState(() => _olorAgua = v.toString())), _buildRadioButton('Químico', _olorAgua, (v) => setState(() => _olorAgua = v.toString())),
                      ])),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
                        _buildRadioButton('Ninguno', _colorAgua, (v) => setState(() => _colorAgua = v.toString())), _buildRadioButton('Blanco', _colorAgua, (v) => setState(() => _colorAgua = v.toString())), _buildRadioButton('Gris', _colorAgua, (v) => setState(() => _colorAgua = v.toString())), _buildRadioButton('Verde', _colorAgua, (v) => setState(() => _colorAgua = v.toString())), _buildRadioButton('Marrón', _colorAgua, (v) => setState(() => _colorAgua = v.toString())),
                      ])),
                    ],
                  )
                ]), const SizedBox(height: 12),

                // --- 10. MEDICIONES ---
                _buildSeccionExpandible(titulo: '10. Mediciones (Cuerpo de Agua)', icono: Icons.straighten_outlined, contenido: [
                  _buildMatrizMediciones('Ancho (m)'), const Divider(height: 32),
                  _buildMatrizMediciones('Profundidad (m)'), const Divider(height: 32),
                  _buildMatrizMediciones('Velocidad (m/s)'), const Divider(height: 32),
                  
                  const Text('Cobertura del dosel', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(children: [
                    Expanded(child: _buildRadioButton('Abierta', _coberturaDosel, (v) => setState(() => _coberturaDosel = v.toString()))),
                    Expanded(child: _buildRadioButton('Cubierta', _coberturaDosel, (v) => setState(() => _coberturaDosel = v.toString()))),
                  ]), const SizedBox(height: 16),
                  
                  const Text('Tipo de morfología (%)', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _buildCampoTexto('Rápidos %', tecladoNumerico: true)), const SizedBox(width: 16),
                    Expanded(child: _buildCampoTexto('Pozas %', tecladoNumerico: true)),
                  ]),
                ]),

                const SizedBox(height: 80), // Espacio extra al final para que el botón flotante no tape
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSeccionExpandible({required String titulo, required IconData icono, required List<Widget> contenido}) {
    return Card(
      elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: Icon(icono, color: Colors.black87)),
          title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          iconColor: const Color(0xFFCCFF00), collapsedIconColor: Colors.grey, childrenPadding: const EdgeInsets.all(20), expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: contenido,
        ),
      ),
    );
  }

  Widget _buildCampoTexto(String etiqueta, {IconData? icono, bool esLectura = false, bool tecladoNumerico = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        readOnly: esLectura, keyboardType: tecladoNumerico ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: etiqueta, filled: true, fillColor: Colors.grey.shade50, suffixIcon: icono != null ? Icon(icono, color: Colors.grey) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCCFF00), width: 2)),
        ),
      ),
    );
  }

  Widget _buildRadioButton(String titulo, String valorGrupo, ValueChanged<String?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(value: titulo, groupValue: valorGrupo, activeColor: const Color(0xFFCCFF00), visualDensity: const VisualDensity(horizontal: -4, vertical: -4), onChanged: onChanged),
        Flexible(child: Text(titulo, style: const TextStyle(fontSize: 14), overflow: TextOverflow.clip)),
      ],
    );
  }

  // Fila rápida para preguntas de Sí / No
  Widget _buildFilaSiNo(String pregunta, String valorActual, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(pregunta, style: const TextStyle(fontSize: 14))),
          Row(children: [
            _buildRadioButton('Sí', valorActual, onChanged), const SizedBox(width: 8),
            _buildRadioButton('No', valorActual, onChanged),
          ]),
        ],
      ),
    );
  }

  Widget _buildCheckboxSencillo(String titulo, Map<String, bool> mapa) {
    return CheckboxListTile(
      title: Text(titulo, style: const TextStyle(fontSize: 14)), value: mapa[titulo], activeColor: const Color(0xFFCCFF00), checkColor: Colors.black87, contentPadding: EdgeInsets.zero, dense: true,
      onChanged: (bool? value) { setState(() { mapa[titulo] = value ?? false; }); },
    );
  }

  // Crea cuadrículas de 2 columnas para muchos checkboxes
  Widget _buildCheckboxGroup(Map<String, bool> opciones) {
    return Wrap(
      spacing: 8.0, runSpacing: 0.0,
      children: opciones.keys.map((String key) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.4, // Ocupa el 40% de la pantalla
          child: _buildCheckboxSencillo(key, opciones),
        );
      }).toList(),
    );
  }

  // Genera la matriz de 9 campos (M0, M50, M100) para el punto 10
  Widget _buildMatrizMediciones(String titulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _buildFilaMatriz('M0'), _buildFilaMatriz('M50'), _buildFilaMatriz('M100'),
      ],
    );
  }

  Widget _buildFilaMatriz(String etiquetaMetro) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 45, child: Text(etiquetaMetro, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
          Expanded(child: _buildCampoPequeno('P1')), const SizedBox(width: 8),
          Expanded(child: _buildCampoPequeno('P2')), const SizedBox(width: 8),
          Expanded(child: _buildCampoPequeno('P3')),
        ],
      ),
    );
  }

  Widget _buildCampoPequeno(String hint) {
    return SizedBox(
      height: 40,
      child: TextFormField(
        keyboardType: TextInputType.number, textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(fontSize: 12, color: Colors.grey), filled: true, fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCCFF00), width: 2)),
        ),
      ),
    );
  }
}