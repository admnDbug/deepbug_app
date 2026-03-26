// Archivo: lib/features/protocolo1/screens/protocolo1_screen.dart

import 'package:flutter/material.dart';

class Protocolo1Screen extends StatefulWidget {
  const Protocolo1Screen({super.key});

  @override
  State<Protocolo1Screen> createState() => _Protocolo1ScreenState();
}

class _Protocolo1ScreenState extends State<Protocolo1Screen> {
  // --- SIMULADOR DE ESTADO PARA LA ADVERTENCIA ---
  // 0 = Sin llenar (Rojo), 1 = Pre-campo listo (Naranja), 2 = Completo (Verde)
  int _estadoProtocolo = 0;

  // --- VARIABLES: 4. PARÁMETROS A EVALUAR (In Situ) ---
  final Map<String, bool> _parametrosInSitu = {
    'Conductividad': false,
    'pH': false,
    'Temperatura': false,
    'Oxígeno disuelto': false,
    'Salinidad': false,
    'Turbiedad': false,
  };

  // --- VARIABLES: 6. VERIFICACIÓN DE MATERIALES ---
  final Map<String, bool> _equipos = {
    'Flujómetro': false,
    'Termómetro': false,
    'Conductivímetro': false,
    'Multiparámetros': false,
    'GPS': false,
    'Cámara fotográfica': false,
  };

  final Map<String, bool> _documentacion = {
    'P-001. Plan de Muestreo': false,
    'P-002. Caracterización Visual y Fisicoquímica': false,
    'P-003a. Caracterización de Hábitat (Alto)': false,
    'P-003b. Caracterización de Hábitat (Bajo)': false,
    'P-004. Muestreo Multihábitat': false,
    'P-005. Análisis de Muestras': false,
  };

  final Map<String, String> _insumos = {
    'Red tipo D': '',
    'Envases plásticos': '',
    'Caja de Herramienta': '',
    'R. Triangular': '',
    'Frascos fisicoq.': '',
    'Tijeras': '',
    'Celular': '',
    'Cinta métrica': '',
    'Bolsas herméticas': '',
    'Lápices': '',
    'C. fluorescentes': '',
    'Tabla anot.': '',
    'Lupas': '',
    'Viales de plásticos': '',
    'Alcohol': '',
    'Tamices': '',
    'Pilotos indelebles': '',
    'C. adhesiva': '',
    'Etiquetas': '',
    'Pinzas entomol.': '',
    'Guantes': '',
    'Bandejas blancas': '',
    'Mascarillas': '',
    'Botellas de lavado': '',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor eliminado para usar el del tema

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                if (_estadoProtocolo == 0) {
                  _estadoProtocolo = 1;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pre-campo guardado. Falta In Situ.'),
                    ),
                  );
                } else if (_estadoProtocolo == 1) {
                  _estadoProtocolo = 2;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Protocolo 1 Completado.')),
                  );
                } else {
                  _estadoProtocolo = 0; // Reinicia para la prueba
                }
              });
            },
            icon: Icon(
              _estadoProtocolo == 2 ? Icons.check_circle : Icons.save_outlined,
            ),
            label: Text(
              _estadoProtocolo == 0
                  ? 'Guardar Pre-Campo (Puntos 1,2,3,5,6)'
                  : _estadoProtocolo == 1
                  ? 'Guardar Datos In Situ (Punto 4)'
                  : 'Reiniciar Prueba',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              // Eliminamos el color fijo para que herede de app_theme.dart
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180.0,
            // Eliminamos backgroundColor fijo
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios), // Color dinámico
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Protocolo 1',
              // Color de texto dinámico a través del tema
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                // Eliminamos color: Colors.white
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plan de Monitoreo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        // Color negro eliminado
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Planificación de equipos y parámetros a medir en campo.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // --- BANNER DE ADVERTENCIA DINÁMICO ---
                _buildBannerAdvertencia(context),

                // 1 y 2. DATOS GENERALES Y OBJETIVO
                _buildSeccionExpandible(
                  context: context,
                  titulo: '1 y 2. Datos Generales y Objetivo',
                  icono: Icons.business_center_outlined,
                  contenido: [
                    _buildCampoTexto(context, 'Nombre del Proyecto'),
                    _buildCampoTexto(context, 'Persona de contacto'),
                    _buildCampoTexto(context, 'Provincia o provincias'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCampoTexto(
                            context,
                            'Fechas de muestreo',
                            icono: Icons.date_range,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCampoTexto(
                            context,
                            'Hora',
                            icono: Icons.access_time,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    const Text(
                      'Objetivo del muestreo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 3. IDENTIFICACIÓN
                _buildSeccionExpandible(
                  context: context,
                  titulo: '3. Identificación',
                  icono: Icons.pin_drop_outlined,
                  contenido: [
                    const Text(
                      'Estación de Muestreo a visitar:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCampoTexto(
                      context,
                      'N° de Control (Generado automáticamente)',
                      esLectura: true,
                      hint: 'Ej. EST-001',
                    ),
                    _buildCampoTexto(context, 'Lugar'),
                    _buildCampoTexto(context, 'Tipo de muestra'),
                  ],
                ),
                const SizedBox(height: 12),

                // 4. PARÁMETROS A EVALUAR (OBLIGATORIO IN SITU)
                _buildSeccionExpandible(
                  context: context,
                  titulo: '4. Parámetros a evaluar (In Situ)',
                  icono: Icons.science_outlined,
                  contenido: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Estas mediciones deben realizarse y marcarse estando en la estación de muestreo.',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 0.0,
                      children: _parametrosInSitu.keys.map((String key) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: _buildCheckboxSencillo(context, key, _parametrosInSitu),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 5. RESPONSABLES
                _buildSeccionExpandible(
                  context: context,
                  titulo: '5. Responsables del Muestreo',
                  icono: Icons.groups_outlined,
                  contenido: [
                    _buildCampoTexto(context, 'Técnicos'),
                    _buildCampoTexto(context, 'Conductor'),
                    _buildCampoTexto(
                      context,
                      'Fecha de elaboración del plan',
                      icono: Icons.calendar_today,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 6. VERIFICACIÓN DE MATERIALES
                _buildSeccionExpandible(
                  context: context,
                  titulo: '6. Verificación de Materiales',
                  icono: Icons.checklist_rtl_outlined,
                  contenido: [
                    Text(
                      'a) Equipos e instrumentos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 0.0,
                      children: _equipos.keys
                          .map(
                            (k) => SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: _buildCheckboxSencillo(context, k, _equipos),
                            ),
                          )
                          .toList(),
                    ),

                    const Divider(height: 32),
                    Text(
                      'b) Información documentada',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._documentacion.keys.map(
                      (k) => _buildCheckboxSencillo(context, k, _documentacion),
                    ),

                    const Divider(height: 32),
                    Text(
                      'c) Materiales e Insumos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Indica la cantidad en unidades:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16.0,
                      runSpacing: 12.0,
                      children: _insumos.keys
                          .map(
                            (k) => SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: _buildInputInsumo(context, k),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

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

  Widget _buildSeccionExpandible({
    required BuildContext context,
    required String titulo,
    required IconData icono,
    required List<Widget> contenido,
  }) {
    return Card(
      // Se heredan colores de CardTheme
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono), // Color dinámico
          ),
          title: Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          iconColor: Theme.of(context).colorScheme.primary, // Color del tema
          collapsedIconColor: Colors.grey,
          childrenPadding: const EdgeInsets.all(20),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: contenido,
        ),
      ),
    );
  }

  Widget _buildCampoTexto(
    BuildContext context,
    String etiqueta, {
    IconData? icono,
    bool esLectura = false,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        readOnly: esLectura,
        decoration: InputDecoration(
          labelText: etiqueta,
          hintText: hint,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          suffixIcon: icono != null ? Icon(icono, color: Colors.grey) : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Sin borde por default
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxSencillo(BuildContext context, String titulo, Map<String, bool> mapa) {
    return CheckboxListTile(
      title: Text(titulo, style: const TextStyle(fontSize: 13)),
      value: mapa[titulo],
      activeColor: Theme.of(context).colorScheme.primary,
      checkColor: Theme.of(context).colorScheme.onPrimary, // Generalmente blanco o negro dependiendo del contraste
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (bool? value) {
        setState(() {
          mapa[titulo] = value ?? false;
        });
      },
    );
  }

  Widget _buildInputInsumo(BuildContext context, String titulo) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          height: 35,
          child: TextFormField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: (v) => _insumos[titulo] = v,
            decoration: InputDecoration(
              hintText: 'Ud.',
              hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}