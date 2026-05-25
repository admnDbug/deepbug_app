// Archivo: lib/features/ia_scanner/screens/scanner_screen.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:provider/provider.dart';

import '../../protocolo5/providers/protocolo5_provider.dart';
import '../../protocolo5/screens/protocolo5_screen.dart';

import 'dart:math' as math;
import 'package:image/image.dart' as img;

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  File? _imagenSeleccionada;
  List<dynamic>? _predicciones;
  bool _estaCargando = false;
  bool _modeloCargado = false;

  @override
  void initState() {
    super.initState();
    _cargarModelo();
  }

  Future<void> _cargarModelo() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/modelo_final_mobilenet.tflite",
        labels: "assets/labels.txt",
        numThreads: 2, 
        isAsset: true,
        useGpuDelegate: false,
      );
      if (res != null) {
        setState(() => _modeloCargado = true);
      }
    } catch (e) {
      debugPrint("Error al cargar el modelo: $e");
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  Future<void> _obtenerImagen(ImageSource fuente) async {
    if (!_modeloCargado) return;

    final ImagePicker picker = ImagePicker();
    final XFile? foto = await picker.pickImage(
      source: fuente,
      imageQuality: 50,
    );

    if (foto != null) {
      setState(() {
        _imagenSeleccionada = File(foto.path);
        _estaCargando = true;
      });
      _clasificarImagen(_imagenSeleccionada!);
    }
  }

  Future<void> _clasificarImagen(File imagen) async {
    final bytes = await imagen.readAsBytes();
    img.Image? originalImage = img.decodeImage(bytes);

    if (originalImage != null) {
      int cropSize = math.min(originalImage.width, originalImage.height);
      int offsetX = (originalImage.width - cropSize) ~/ 2;
      int offsetY = (originalImage.height - cropSize) ~/ 2;

      img.Image croppedImage = img.copyCrop(originalImage,
          x: offsetX, y: offsetY, width: cropSize, height: cropSize);

      await imagen.writeAsBytes(img.encodeJpg(croppedImage));
    }
    var predicciones = await Tflite.runModelOnImage(
      path: imagen.path,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 5, 
      threshold: 0.1,
      asynch: true,
    );

    setState(() {
      _predicciones = predicciones;
      _estaCargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identificación IA', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  image: _imagenSeleccionada != null
                      ? DecorationImage(
                          image: FileImage(_imagenSeleccionada!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imagenSeleccionada == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.center_focus_weak, size: 60, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text('Sube o toma una foto del\nmacroinvertebrado', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      )
                    : null,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _obtenerImagen(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Cámara'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _obtenerImagen(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galería'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, -4))],
                ),
                child: _estaCargando
                    ? const Center(child: CircularProgressIndicator())
                    : _predicciones == null || _predicciones!.isEmpty
                        ? Center(child: Text('Esperando imagen...', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Mejores coincidencias:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _predicciones!.length,
                                  itemBuilder: (context, index) {
                                    final res = _predicciones![index];
                                    String nombreFamiliaTFLite = res['label'].toString().replaceAll(RegExp(r'^[0-9]+\s'), '');
                                    double porcentaje = (res['confidence'] * 100);

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                          child: Text('${porcentaje.toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                                        ),
                                        title: Text(nombreFamiliaTFLite, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        trailing: ElevatedButton(
                                          onPressed: () => _agregarDesdeIA(context, nombreFamiliaTFLite),
                                          child: const Text('Agregar'),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const Divider(),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CatalogoManualScreen()));
                                },
                                icon: const Icon(Icons.search_off),
                                label: const Text('No es ninguno, ir al catálogo manual'),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                              ),
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _agregarDesdeIA(BuildContext context, String nombreBuscado) async {
    final provider = Provider.of<Protocolo5Provider>(context, listen: false);
    
    final match = provider.catalogo.where((f) => f.nombre.toLowerCase() == nombreBuscado.toLowerCase()).firstOrNull;

    if (match != null) {
      String? base64String;
      
      if (_imagenSeleccionada != null) {
        final bytes = await _imagenSeleccionada!.readAsBytes();
        base64String = base64Encode(bytes);
      }

      provider.agregarFamilia(match, fotoBase64: base64String);
      
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${match.nombre} agregado con evidencia!'), backgroundColor: Colors.green));
        Navigator.pop(context); 
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('La familia $nombreBuscado no está habilitada en el catálogo de la BD.'), backgroundColor: Colors.orange));
    }
  }
}