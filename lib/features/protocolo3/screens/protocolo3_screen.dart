// Archivo: lib/features/protocolo3/screens/protocolo3_screen.dart

import 'package:flutter/material.dart';

class Protocolo3Screen extends StatefulWidget {
  const Protocolo3Screen({super.key});

  @override
  State<Protocolo3Screen> createState() => _Protocolo3ScreenState();
}

class _Protocolo3ScreenState extends State<Protocolo3Screen> {
  // --- TIPO DE GRADIENTE ---
  String _tipoGradiente = 'Alto'; // Puede ser 'Alto' o 'Bajo'

  // --- CAJAS INDEPENDIENTES DE PUNTUACIÓN ---
  final Map<String, double> _puntajesAlto = {
    'p1': 0, 'p2': 0, 'p3': 0, 'p4': 0, 'p5': 0, 'p6': 0, 'p7': 0,
    'p8Izq': 0, 'p8Der': 0, 'p9Izq': 0, 'p9Der': 0, 'p10Izq': 0, 'p10Der': 0,
  };

  final Map<String, double> _puntajesBajo = {
    'p1': 0, 'p2': 0, 'p3': 0, 'p4': 0, 'p5': 0, 'p6': 0, 'p7': 0,
    'p8Izq': 0, 'p8Der': 0, 'p9Izq': 0, 'p9Der': 0, 'p10Izq': 0, 'p10Der': 0,
  };

  Map<String, double> get _puntajesActuales =>
      _tipoGradiente == 'Alto' ? _puntajesAlto : _puntajesBajo;

  int get _puntajeTotal =>
      _puntajesActuales.values.fold(0.0, (sum, val) => sum + val).toInt();

  // Los colores de estado (Rojo, Amarillo, Verde) los conservamos igual porque son semánticos
  Color _obtenerColorCategoria(double valor, {bool esMitad = false}) {
    double maximo = esMitad ? 10 : 20;
    double porcentaje = valor / maximo;
    if (porcentaje >= 0.8) return Colors.green;
    if (porcentaje >= 0.55) return Colors.yellow.shade700;
    if (porcentaje >= 0.3) return Colors.orange;
    return Colors.red;
  }

  String _obtenerTextoCategoria(double valor, {bool esMitad = false}) {
    double maximo = esMitad ? 10 : 20;
    double porcentaje = valor / maximo;
    if (porcentaje >= 0.8) return 'Óptimo';
    if (porcentaje >= 0.55) return 'Subóptimo';
    if (porcentaje >= 0.3) return 'Marginal';
    return 'Pobre';
  }

  @override
  Widget build(BuildContext context) {
    bool esAlto = _tipoGradiente == 'Alto';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Quitamos backgroundColor
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            // El contenedor inferior ahora usa el color surface para adaptarse
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PUNTAJE TOTAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '$_puntajeTotal / 200',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        // Quitamos color black87
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Protocolo 3 Guardado')),
                ),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  // Hereda colores de app_theme.dart
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160.0,
            // Quitamos backgroundColor y surfaceTintColor
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios), // Quitamos color black87
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Protocolo 3',
              // Color de texto heredado
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                // Quitamos color white
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Caracterización del Hábitat',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        // Quitamos color black87
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecciona el tipo de gradiente y evalúa los parámetros.',
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
                // --- SELECTOR DE GRADIENTE DINÁMICO ---
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest, // Gris suave dinámico
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tipoGradiente = 'Alto'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              // La pestaña activa toma el color de fondo base (surface)
                              color: esAlto ? Theme.of(context).colorScheme.surface : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: esAlto
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Gradiente Alto',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: esAlto ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tipoGradiente = 'Bajo'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !esAlto ? Theme.of(context).colorScheme.surface : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: !esAlto
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Gradiente Bajo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: !esAlto ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, left: 8),
                  child: Text(
                    'PARÁMETROS GENERALES (0-20 Puntos)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                // 3.1 Heterogeneidad
                _buildSliderParametro(
                  titulo: '1. Heterogeneidad y estabilidad del sustrato',
                  valorActual: _puntajesActuales['p1']!,
                  onChanged: (v) => setState(() => _puntajesActuales['p1'] = v),
                  onInfoTap: () => _mostrarInformacionParametro(
                    'Heterogeneidad y estabilidad',
                    esAlto
                        ? 'Más del 70 % (más del 50 % para gradiente bajo) del sustrato es heterogéneo y estable para ser colonizado.'
                        : 'Más de 70 % del sustrato es estable y puede ser colonizado por la epifauna. El tramo presenta una mezcla de piedras, troncos sumergidos o superficiales o cualquier otro sustrato estable.',
                    esAlto
                        ? '40-70 % del sustrato es heterogéneo y estable. Existe un sustrato nuevo o poco estable.'
                        : 'Entre 40 y 70 % del sustrato es estable. Aún existe un sustrato nuevo aun sin condiciones para ser habitado.',
                    esAlto
                        ? '20-40 % del sustrato es heterogéneo y estable. La mayor parte del sustrato está perturbado o removido.'
                        : 'Entre 20 y 40 % del sustrato es estable. Frecuentemente perturbado o removido.',
                    esAlto
                        ? 'Menos de un 20 % del sustrato es heterogéneo y estable. Ausencia de hábitats disponibles.'
                        : 'Menos de un 20 % del sustrato es estable. Ausencia de hábitats adecuados.',
                  ),
                ),

                // 3.2 Empotramiento / Caracterización de pozas
                _buildSliderParametro(
                  titulo: esAlto
                      ? '2. Empotramiento del sustrato'
                      : '2. Caracterización del sustrato de pozas',
                  valorActual: _puntajesActuales['p2']!,
                  onChanged: (v) => setState(() => _puntajesActuales['p2'] = v),
                  onInfoTap: () => _mostrarInformacionParametro(
                    esAlto ? 'Empotramiento del sustrato' : 'Sustrato de pozas',
                    esAlto
                        ? '0-25 % de la superficie de rocas, piedras y grava está rodeada de sedimento fino.'
                        : 'Mezcla de sustrato, con grava y arena firme prevalente. Raíces y vegetación sumergida.',
                    esAlto
                        ? '25-50 % de la superficie de rocas, piedras y grava rodeadas de sedimento fino.'
                        : 'Mezcla de arena blanda, barro o arcilla; el barro puede ser dominante. Algunas raíces y vegetación sumergida presente.',
                    esAlto
                        ? '50-75% de la superficie de rocas, piedras y grava rodeadas de sedimento fino.'
                        : 'Todo el barro, arcilla o arena en la parte inferior. Poca o ninguna raíz, no hay vegetación sumergida.',
                    esAlto
                        ? 'Más del 75 % de la superficie de rocas, piedras y grava rodeadas de sedimento fino.'
                        : 'Arcilla dura o lecho de roca. No hay capas de raíces o vegetación.',
                  ),
                ),

                // 3.3 Relación Profundidad / Variabilidad
                _buildSliderParametro(
                  titulo: esAlto
                      ? '3. Relación profundidad y velocidad'
                      : '3. Variabilidad de las pozas',
                  valorActual: _puntajesActuales['p3']!,
                  onChanged: (v) => setState(() => _puntajesActuales['p3'] = v),
                  onInfoTap: () => _mostrarInformacionParametro(
                    esAlto
                        ? 'Relación profundidad y velocidad'
                        : 'Variabilidad de las pozas',
                    esAlto
                        ? 'El tramo del río presenta las cuatro combinaciones: a) lento/profundo, b) lento/bajo, c) rápido/profundo, d) rápido/bajo.'
                        : 'Mezcla de pozas superficiales, poco profundas, profundas y de gran profundidad.',
                    esAlto
                        ? 'Sólo tres combinaciones. La ausencia de rápido/bajo determina el menor puntaje.'
                        : 'La mayoría de las pozas a gran profundidad; muy pocas superficiales.',
                    esAlto
                        ? 'Sólo dos combinaciones. La ausencia de rápido/bajo determina el menor puntaje.'
                        : 'Pozas superficiales mucho más frecuente que las pozas profundas.',
                    esAlto
                        ? 'Una sola combinación presente. Usualmente lento/profundo.'
                        : 'La mayoría de las pozas de poca profundidad o pozas ausente.',
                  ),
                ),

                // 3.4 Deposición
                _buildSliderParametro(
                  titulo: '4. Deposición de sedimentos',
                  valorActual: _puntajesActuales['p4']!,
                  onChanged: (v) => setState(() => _puntajesActuales['p4'] = v),
                  onInfoTap: () => _mostrarInformacionParametro(
                    'Deposición de sedimentos',
                    'Poca presencia de islas o barreras, menos del 20 % del fondo afectado por deposición de sedimentos.',
                    'Aumento de la formación de barreras, principalmente de canto rodado, arena o sedimento fino. 20-50 % del fondo afectado, poca deposición en pozas.',
                    'Deposición moderada de canto rodado, grava y sedimento fino en barras viejas y nuevas. Del 50-80 % del fondo afectado.',
                    'Depósitos grandes de material fino, incremento del desarrollo de barras, más del 80 % del fondo afectado.',
                  ),
                ),

                // 3.5 Flujo
                _buildSliderParametro(
                  titulo: '5. Estado del flujo del cauce',
                  valorActual: _puntajesActuales['p5']!,
                  onChanged: (v) => setState(() => _puntajesActuales['p5'] = v),
                  onInfoTap: () => _mostrarInformacionParametro(
                    'Estado del flujo del cauce',
                    'El nivel del agua alcanza la base de los márgenes y la exposición del sustrato de fondo es mínima.',
                    'El agua sólo cubre el 75 % del cauce o menos del 25 % del sustrato de fondo queda expuesto.',
                    'El nivel del agua cubre entre el 25 y 75 % del cauce y queda expuesta la mayor parte del sustrato de los rápidos.',
                    'Muy poca agua sobre el cauce y la mayoría como pozos.',
                  ),
                ),

                // 3.6 Alteración
                _buildSliderParametro(
                  titulo: '6. Alteración del cauce',
                  valorActual: _puntajesActuales['p6']!,
                  onChanged: (v) => setState(() => _puntajesActuales['p6'] = v),
                  onInfoTap: () => _mostrarInformacionParametro(
                    'Alteración del cauce',
                    'Ausencia o mínima presencia de canalización o dragado. Corriente con cauce normal.',
                    'Cierta canalización presente por puentes. Evidencia de canalización actual o pasada.',
                    'Canalización extensiva. Diques u otras estructuras presentes en ambas márgenes. Entre el 40 y 80% del trecho del río canalizado y alterado.',
                    'Márgenes protegidas con gabiones o cemento. Más del 80 % del trecho del río canalizada y alterado. Los hábitats internos eliminados totalmente.',
                  ),
                ),

                // 3.7 Rápidos / Sinuosidad
                _buildSliderParametro(
                  titulo: esAlto
                      ? '7. Frecuencia de rápidos'
                      : '7. Sinuosidad del canal',
                  valorActual: _puntajesActuales['p7']!,
                  onChanged: (v) => setState(() => _puntajesActuales['p7'] = v),
                  onInfoTap: () => _mostrarInformacionParametro(
                    esAlto ? 'Frecuencia de rápidos' : 'Sinuosidad del canal',
                    esAlto
                        ? 'Ocurrencia de rápidos relativamente frecuente. Distancia entre rápidos y ancho es < 7.'
                        : 'Las curvas en la corriente aumentan la longitud de flujo 3 a 4 veces más tiempo que si estuviera en una línea recta.',
                    esAlto
                        ? 'Ocurrencia de rápidos poco frecuente. Distancia entre rápidos y ancho entre 7 y 15.'
                        : 'Las curvas en la corriente aumentan la longitud de flujo 1 a 2 veces más tiempo que si estuviera en una línea recta.',
                    esAlto
                        ? 'Ocurrencia ocasional de rápidos. Distancia entre rápidos y ancho se encuentra entre 15 y 25.'
                        : 'Las curvas en la corriente aumentan la longitud de flujo 1 a 2 veces más tiempo que si estuviera en una línea recta.',
                    esAlto
                        ? 'Por lo general el agua corre sin interrupción o rápidos muy bajos. Distancia mayor a 25.'
                        : 'Canal recto; vía fluvial ha sido canalizada por una larga distancia.',
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 16.0, left: 8),
                  child: Text(
                    'PARÁMETROS POR MARGEN (0-10 Puntos c/u)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                // 3.8 Estabilidad ribera
                _buildSliderMargenes(
                  titulo: '8. Estabilidad de la ribera',
                  valIzq: _puntajesActuales['p8Izq']!,
                  valDer: _puntajesActuales['p8Der']!,
                  onChangedIzq: (v) =>
                      setState(() => _puntajesActuales['p8Izq'] = v),
                  onChangedDer: (v) =>
                      setState(() => _puntajesActuales['p8Der'] = v),
                  onInfoTap: () => _mostrarInformacionParametro(
                    'Estabilidad de la ribera',
                    'Orillas estables, mínima o ausente evidencia de erosión de las orillas, <5 % de las orillas afectadas.',
                    'Orilla moderadamente estable, pequeñas áreas de erosión, 5-30 % de la orilla está erosionada.',
                    'Ribera del 30-60 % de erosión en las orillas, alto potencial de erosión de orillas durante descargas.',
                    'Orillas poco estables, entre 60-100 % están erosionadas.',
                  ),
                ),

                // 3.9 Vegetación protectora
                _buildSliderMargenes(
                  titulo: '9. Vegetación protectora de la ribera',
                  valIzq: _puntajesActuales['p9Izq']!,
                  valDer: _puntajesActuales['p9Der']!,
                  onChangedIzq: (v) =>
                      setState(() => _puntajesActuales['p9Izq'] = v),
                  onChangedDer: (v) =>
                      setState(() => _puntajesActuales['p9Der'] = v),
                  onInfoTap: () => _mostrarInformacionParametro(
                    'Vegetación protectora de la ribera',
                    'Más del 90 % de las márgenes y la zona ribereña está cubierta por vegetación nativa incluyendo árboles, arbustos, macrófitas.',
                    'Entre el 70 y 90 % de las márgenes cubiertas por vegetación nativa. Vegetación algo abierta.',
                    'Entre el 50 y 70 % de las márgenes cubiertas por vegetación nativa. Vegetación abierta.',
                    'Menos del 50 % de las márgenes cubiertas por vegetación nativa.',
                  ),
                ),

                // 3.10 Amplitud vegetación
                _buildSliderMargenes(
                  titulo: '10. Amplitud de la vegetación ribereña',
                  valIzq: _puntajesActuales['p10Izq']!,
                  valDer: _puntajesActuales['p10Der']!,
                  onChangedIzq: (v) =>
                      setState(() => _puntajesActuales['p10Izq'] = v),
                  onChangedDer: (v) =>
                      setState(() => _puntajesActuales['p10Der'] = v),
                  onInfoTap: () => _mostrarInformacionParametro(
                    'Amplitud de la vegetación ribereña',
                    'Extensión de la vegetación ribereña mayor a 18 m y sin impacto antrópico.',
                    'Extensión de la vegetación ribereña entre 12 y 18 m y un mínimo impacto.',
                    'Extensión de la vegetación ribereña entre 6 y 12 m y un impacto evidente.',
                    'Extensión de la vegetación ribereña menor a 6 m. Poca o ninguna vegetación debido a un fuerte impacto.',
                  ),
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

  Widget _buildSliderParametro({
    required String titulo,
    required double valorActual,
    required ValueChanged<double> onChanged,
    required VoidCallback onInfoTap,
  }) {
    Color colorCategoria = _obtenerColorCategoria(valorActual);
    return Card(
      // Quitamos colores, sombras y bordes, heredamos del app_theme.dart
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onInfoTap,
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorCategoria.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${valorActual.toInt()} pts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorCategoria,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _obtenerTextoCategoria(valorActual),
              style: TextStyle(
                color: colorCategoria,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: colorCategoria,
                // Color inactivo adaptado al modo
                inactiveTrackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                thumbColor: colorCategoria,
                overlayColor: colorCategoria.withOpacity(0.2),
                valueIndicatorColor: colorCategoria,
              ),
              child: Slider(
                value: valorActual,
                min: 0,
                max: 20,
                divisions: 20,
                label: valorActual.toInt().toString(),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderMargenes({
    required String titulo,
    required double valIzq,
    required double valDer,
    required ValueChanged<double> onChangedIzq,
    required ValueChanged<double> onChangedDer,
    required VoidCallback onInfoTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onInfoTap,
                ),
              ],
            ),
            const Divider(height: 24),
            _buildMiniSlider('M. Izquierdo', valIzq, onChangedIzq),
            const SizedBox(height: 8),
            _buildMiniSlider('M. Derecho', valDer, onChangedDer),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniSlider(
    String etiqueta,
    double valorActual,
    ValueChanged<double> onChanged,
  ) {
    Color colorCategoria = _obtenerColorCategoria(valorActual, esMitad: true);
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              Text(
                '${valorActual.toInt()} pts',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorCategoria,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorCategoria,
              inactiveTrackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              thumbColor: colorCategoria,
              overlayColor: colorCategoria.withOpacity(0.2),
              trackHeight: 3,
            ),
            child: Slider(
              value: valorActual,
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _mostrarInformacionParametro(
    String titulo,
    String optimo,
    String suboptimo,
    String marginal,
    String pobre,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Quitamos backgroundColor: Colors.white
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final double safePaddingBottom = MediaQuery.of(context).padding.bottom;
        return Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, safePaddingBottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Criterios: $titulo',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCajaCriterio('Óptimo (20 - 16 pts)', optimo, Colors.green),
              _buildCajaCriterio(
                'Subóptimo (15 - 11 pts)',
                suboptimo,
                Colors.yellow.shade700,
              ),
              _buildCajaCriterio(
                'Marginal (10 - 6 pts)',
                marginal,
                Colors.orange,
              ),
              _buildCajaCriterio('Pobre (5 - 0 pts)', pobre, Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCajaCriterio(String titulo, String descripcion, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        border: Border(left: BorderSide(color: color, width: 4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            descripcion,
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}