import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../models/ingredient_analysis.dart';
import '../services/api_service.dart';
import '../services/ocr_service.dart';
import '../services/ingredient_parser.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _ingredientsController =
      TextEditingController();

  final ApiService _apiService = ApiService();

  final OcrService _ocrService = OcrService();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;

  IngredientAnalysisResponse? _result;
  bool _loading = false;
  bool _ingredientsDetectedFromCamera = false;
  String? _error;

  Future<void> _takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) {
      return;
    }

    final croppedImage = await _cropImage(File(image.path));

    if (croppedImage == null) {
      return;
    }

    setState(() {
      _selectedImage = croppedImage;
      _ingredientsDetectedFromCamera = false;
    });
  }

  Future<File?> _cropImage(File image) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 95,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Selecciona los ingredientes',
          lockAspectRatio: false,
          showCropGrid: true,
        ),
        IOSUiSettings(
          title: 'Selecciona los ingredientes',
        ),
        WebUiSettings(context: context),
      ],
    );

    if (croppedFile == null) {
      return null;
    }

    return File(croppedFile.path);
  }

  Future<void> _adjustIngredientArea() async {
    if (_selectedImage == null) {
      return;
    }

    final croppedImage = await _cropImage(_selectedImage!);

    if (croppedImage == null) {
      return;
    }

    setState(() {
      _selectedImage = croppedImage;
      _ingredientsDetectedFromCamera = false;
    });
  }

  Future<void> _scanIngredients() async {
    if (_selectedImage == null) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      // 1. OCR
      final text = await _ocrService.extractText(_selectedImage!);

      // 2. Extraer únicamente los ingredientes
      final ingredients = IngredientParser.parse(
        text,
        requireIngredientHeading: true,
      );

      if (ingredients.isEmpty) {
        setState(() {
          _loading = false;
          _error =
              'No se encontró una sección "Ingredientes:" en la imagen.';
        });
        return;
      }

      // 3. Mostrar ingredientes para que el usuario pueda editarlos.
      setState(() {
        _ingredientsController.text = ingredients.join(', ');
        _ingredientsDetectedFromCamera = true;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'No se pudo procesar la imagen.';
      });
    }
  }


  Future<void> _analyzeIngredients() async {
    final text = _ingredientsController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _error = 'No hay ingredientes para analizar.';
      });
      return;
    }

    final ingredients = IngredientParser.parse(text);

    if (ingredients.isEmpty) {
      setState(() {
        _error = 'No se pudieron identificar ingredientes.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await _apiService.analyzeIngredients(ingredients);

      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'No se pudieron analizar los ingredientes.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'INCI Lens',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHero(),

            const SizedBox(height: 10),

            Text(
              'Ingresa la lista de ingredientes separada por comas '
              'para conocer sus funciones y características.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _ingredientsController,
              maxLines: 7,
              decoration: InputDecoration(
                hintText:
                    'Aqua, Glycerin, Niacinamide, Salicylic Acid...',
                alignLabelWithHint: true,
                labelText: 'Ingredientes',
                helperText: _ingredientsDetectedFromCamera
                    ? 'Revisa y ajusta el texto detectado antes de analizarlo.'
                    : null,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _ingredientsController.clear();
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Escanear etiqueta con cámara'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            
            if (_selectedImage != null) ...[
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _loading ? null : _adjustIngredientArea,
                icon: const Icon(Icons.crop),
                label: const Text('Ajustar área de ingredientes'),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _loading ? null : _scanIngredients,
                icon: const Icon(Icons.document_scanner),
                label: const Text('Leer ingredientes'),
              ),
            ],

            if (_selectedImage != null) ...[
              const SizedBox(height: 16),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _analyzeIngredients,
                icon: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _loading ? 'Analizando...' : 'Analizar ingredientes',
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF176B63),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (_error != null)
              _buildError(),

            if (_result != null)
              _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF176B63), Color(0xFF2B8C7E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33176B63),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0x33FFFFFF),
            child: Icon(Icons.spa_outlined, color: Colors.white),
          ),
          SizedBox(height: 20),
          Text(
            'Conoce tu fórmula',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Escanea, revisa y entiende cada ingrediente.',
            style: TextStyle(color: Color(0xE6FFFFFF), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final result = _result!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resultados',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        _buildSummary(result),

        const SizedBox(height: 20),

        ...result.ingredients.map(
          (ingredient) => _buildIngredientCard(ingredient),
        ),
      ],
    );
  }

  Widget _buildSummary(IngredientAnalysisResponse result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            result.totalIngredients.toString(),
            'Total',
          ),
          _buildSummaryItem(
            result.foundIngredients.toString(),
            'Encontrados',
          ),
          _buildSummaryItem(
            result.notFoundIngredients.toString(),
            'No encontrados',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientCard(
    IngredientAnalysisItem ingredient,
  ) {
    if (!ingredient.found) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.help_outline),
          ),
          title: Text(
            ingredient.inputName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: const Text(
            'No encontrado en la base de datos.',
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  child: Icon(Icons.check),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ingredient.inciName ?? ingredient.inputName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (ingredient.commonName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            ingredient.commonName!,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            if (ingredient.description != null) ...[
              const SizedBox(height: 16),
              Text(
                ingredient.description!,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],

            if (ingredient.category != null) ...[
              const SizedBox(height: 16),
              _buildSectionTitle('Categoría'),
              const SizedBox(height: 6),
              Chip(
                label: Text(ingredient.category!),
              ),
            ],

            if (ingredient.functions.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSectionTitle('Funciones'),
              const SizedBox(height: 6),
              _buildChips(ingredient.functions),
            ],

            if (ingredient.skinTypes.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSectionTitle('Tipos de piel'),
              const SizedBox(height: 6),
              _buildChips(ingredient.skinTypes),
            ],

            if (ingredient.evidenceLevel != null) ...[
              const SizedBox(height: 12),
              _buildSectionTitle('Nivel de evidencia'),
              const SizedBox(height: 6),
              Chip(
                avatar: const Icon(
                  Icons.verified_outlined,
                  size: 18,
                ),
                label: Text(ingredient.evidenceLevel!),
              ),
            ],

            if (ingredient.precautions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Precauciones',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ingredient.precautions.join(' '),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildChips(List<String> values) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: values
          .map(
            (value) => Chip(
              label: Text(value),
            ),
          )
          .toList(),
    );
  }

  @override
  void dispose() {
    _ingredientsController.dispose();
    _ocrService.dispose();
    super.dispose();
  }
}
