// Archivo: lib/features/protocolo4/screens/protocolo4_screen.dart

import 'package:flutter/material.dart';

class Protocolo4Screen extends StatefulWidget {
  const Protocolo4Screen({super.key});

  @override
  State<Protocolo4Screen> createState() => _Protocolo4ScreenState();
}

class _Protocolo4ScreenState extends State<Protocolo4Screen> {
  // --- VARIABLES: 3. TIPOS DE HÁBITAT ---
  String _porcentajeH1 = '',
      _porcentajeH2 = '',
      _porcentajeH3 = '',
      _porcentajeH4 = '',
      _porcentajeH5 = '';
  String _arrastresH1 = '',
      _arrastresH2 = '',
      _arrastresH3 = '',
      _arrastresH4 = '',
      _arrastresH5 = '';
  String _metodoColecta = '';

  // --- VARIABLES: 4. FAUNA ASOCIADA (0 a 4) ---
  final Map<String, int> _faunaAsociada = {
    'Perifiton': 0,
    'Algas filament.': 0,
    'Macrófitas': 0,
    'Macroinvertebrados': 0,
    'Peces': 0,
    'Porífera': 0,
  };

  // --- VARIABLES: 5. ESTIMACIÓN PRELIMINAR (0 a 4) ---
  final Map<String, int> _estimacionPreliminar = {
    'Gasteropoda': 0,
    'Bivalvia': 0,
    'Turbellaria': 0,
    'Oligochaeta': 0,
    'Hirudinea': 0,
    'Diptera': 0,
    'Amphipoda': 0,
    'Isopoda': 0,
    'Cangrejo': 0,
    'Camarón': 0,
    'Ephemeroptera': 0,
    'Plecoptera': 0,
    'Odonata': 0,
    'Hemiptera': 0,
    'Megaloptera': 0,
    'Trichoptera': 0,
    'Lepidoptera': 0,
    'Coleoptera': 0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Quitamos el color de fondo fijo
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Protocolo 4 Guardado')),
            ),
            icon: const Icon(Icons.save_outlined),
            label: const Text(
              'Guardar Progreso',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              // Eliminamos colores fijos para que herede de app_theme.dart
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160.0,
            // Eliminamos colores fijos
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Protocolo 4',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                // Eliminamos color blanco fijo
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Muestreo Multihábitat',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Porcentajes, arrastres y estimación de macroinvertebrados.',
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
                // 3. TIPOS DE HÁBITAT
                _buildSeccionExpandible(
                  context: context,
                  titulo: 'Tipos de Hábitat',
                  icono: Icons.pie_chart_outline,
                  contenido: [
                    Text(
                      'Determinación de los tipos y su porcentaje',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFilaPorcentaje(
                      context,
                      'Hábitat 1. Sustrato duro rápidos',
                      _porcentajeH1,
                      (v) => setState(() => _porcentajeH1 = v),
                    ),
                    _buildFilaPorcentaje(
                      context,
                      'Hábitat 2. Detrito Vegetal',
                      _porcentajeH2,
                      (v) => setState(() => _porcentajeH2 = v),
                    ),
                    _buildFilaPorcentaje(
                      context,
                      'Hábitat 3. Orillas vegetadas',
                      _porcentajeH3,
                      (v) => setState(() => _porcentajeH3 = v),
                    ),
                    _buildFilaPorcentaje(
                      context,
                      'Hábitat 4. Macrófitas acuáticas',
                      _porcentajeH4,
                      (v) => setState(() => _porcentajeH4 = v),
                    ),
                    _buildFilaPorcentaje(
                      context,
                      'Hábitat 5. Arena u otros sedimen.',
                      _porcentajeH5,
                      (v) => setState(() => _porcentajeH5 = v),
                    ),
                    _buildCampoTexto(context, 'Otros (Especificar):'),

                    const Divider(height: 32),
                    Text(
                      'Cálculo del número de arrastres por tipo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFilaArrastre(
                            context,
                            'H1',
                            _arrastresH1,
                            (v) => setState(() => _arrastresH1 = v),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFilaArrastre(
                            context,
                            'H4',
                            _arrastresH4,
                            (v) => setState(() => _arrastresH4 = v),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFilaArrastre(
                            context,
                            'H2',
                            _arrastresH2,
                            (v) => setState(() => _arrastresH2 = v),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFilaArrastre(
                            context,
                            'H5',
                            _arrastresH5,
                            (v) => setState(() => _arrastresH5 = v),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFilaArrastre(
                            context,
                            'H3',
                            _arrastresH3,
                            (v) => setState(() => _arrastresH3 = v),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildCampoTexto(
                      context,
                      'Método de colecta:',
                      onChanged: (v) => setState(() => _metodoColecta = v),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4. FAUNA ASOCIADA
                _buildSeccionExpandible(
                  context: context,
                  titulo: 'Fauna Asociada',
                  icono: Icons.pets_outlined,
                  contenido: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '0 = Ausente\n1 = Rara (1-3 org.)\n2 = Común (3-9)\n3 = Abundante (>10 org.)\n4 = Dominante (>50 org.)',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._faunaAsociada.keys.map(
                      (key) => _buildEscala0a4(
                        context,
                        key,
                        _faunaAsociada[key]!,
                        (val) => setState(() => _faunaAsociada[key] = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 5. ESTIMACIÓN PRELIMINAR
                _buildSeccionExpandible(
                  context: context,
                  titulo: 'Estimación Preliminar (Campo)',
                  icono: Icons.bug_report_outlined,
                  contenido: [
                    Text(
                      'Abundancia estimada de macroinvertebrados:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16.0,
                      runSpacing: 8.0,
                      children: _estimacionPreliminar.keys.map((key) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.38,
                          child: _buildEscala0a4(
                            context,
                            key,
                            _estimacionPreliminar[key]!,
                            (val) => setState(
                              () => _estimacionPreliminar[key] = val,
                            ),
                            modoCompacto: true,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 6. OBSERVACIONES
                _buildSeccionExpandible(
                  context: context,
                  titulo: 'Observaciones',
                  icono: Icons.notes_outlined,
                  contenido: [
                    TextFormField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Escribe aquí cualquier comentario adicional...',
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

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildSeccionExpandible({
    required BuildContext context,
    required String titulo,
    required IconData icono,
    required List<Widget> contenido,
  }) {
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono),
          ),
          title: Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          iconColor: Theme.of(context).colorScheme.primary,
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
    bool tecladoNumerico = false,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        readOnly: esLectura,
        keyboardType: tecladoNumerico
            ? TextInputType.number
            : TextInputType.text,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: etiqueta,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          suffixIcon: icono != null ? Icon(icono, color: Colors.grey) : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildFilaPorcentaje(
    BuildContext context,
    String etiqueta,
    String valorActual,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(etiqueta, style: const TextStyle(fontSize: 14))),
          SizedBox(
            width: 80,
            height: 40,
            child: TextFormField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: onChanged,
              decoration: InputDecoration(
                suffixText: '%',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilaArrastre(
    BuildContext context,
    String etiqueta,
    String valorActual,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            etiqueta,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextFormField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: onChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscala0a4(
    BuildContext context,
    String titulo,
    int valorActual,
    ValueChanged<int> onSelected, {
    bool modoCompacto = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: modoCompacto ? 12 : 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              bool isSelected = valorActual == index;
              return GestureDetector(
                onTap: () => onSelected(index),
                child: Container(
                  width: modoCompacto ? 24 : 35,
                  height: modoCompacto ? 24 : 35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    // Si está seleccionado, usa el color primario, si no, usa el color de fondo base
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      // Borde primario si está seleccionado, borde sutil si no
                      color: isSelected ? Theme.of(context).colorScheme.primary : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    index.toString(),
                    style: TextStyle(
                      // Texto blanco si está seleccionado, sino color de texto normal
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: modoCompacto ? 12 : 14,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}