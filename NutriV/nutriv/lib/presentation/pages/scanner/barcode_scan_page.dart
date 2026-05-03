import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../bloc/barcode/barcode_scanner_bloc.dart';
import '../../bloc/barcode/barcode_scanner_event.dart';
import '../../bloc/barcode/barcode_scanner_state.dart';
import '../../../domain/entities/food_item.dart';

class BarcodeScanPage extends StatefulWidget {
  const BarcodeScanPage({super.key});

  @override
  State<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage> {
  late MobileScannerController _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner de Código de Barras'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: BlocConsumer<BarcodeScannerBloc, BarcodeScannerState>(
        listener: (context, state) {
          if (state is BarcodeScannerSuccess && state.food != null) {
            _showFoodFoundDialog(context, state);
          } else if (state is BarcodeNotFound) {
            _showNotFoundDialog(context, state.barcode);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  if (!_isProcessing) {
                    _isProcessing = true;
                    final barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty &&
                        barcodes.first.rawValue != null) {
                      context.read<BarcodeScannerBloc>().add(
                            BarcodeDetected(barcodes.first.rawValue!),
                          );
                    }
                  }
                },
              ),
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Aponte para o código de barras',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              if (state is BarcodeScannerScanning || _isProcessing)
                const Center(child: CircularProgressIndicator()),
              Positioned(
                bottom: 100,
                left: 24,
                right: 24,
                child: ElevatedButton.icon(
                  onPressed: _showManualEntryDialog,
                  icon: const Icon(Icons.edit),
                  label: const Text('Inserir manualmente'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showManualEntryDialog() {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();
    final portionController = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inserir alimento manualmente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do alimento',
                  hintText: 'Ex: Arroz cozido',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: caloriesController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Calorias (kcal)',
                  hintText: 'Ex: 130',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: proteinController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Proteína (g)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: carbsController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Carbos (g)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: fatController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Gordura (g)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: portionController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Porção (g)',
                  hintText: 'Ex: 100',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final calories = double.tryParse(caloriesController.text) ?? 0;
              final protein = double.tryParse(proteinController.text) ?? 0;
              final carbs = double.tryParse(carbsController.text) ?? 0;
              final fat = double.tryParse(fatController.text) ?? 0;
              final portion = double.tryParse(portionController.text) ?? 100;

              if (name.isEmpty || calories == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preencha pelo menos o nome e calorias'),
                  ),
                );
                return;
              }

              final foodItem = FoodItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                portion: portion,
                portionUnit: 'g',
              );

              Navigator.pop(ctx);
              Navigator.pop(context, foodItem);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showFoodFoundDialog(BuildContext context, BarcodeScannerSuccess state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alimento Encontrado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.food!.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Calorias: ${state.food!.calories.toInt()} kcal'),
            Text('Proteína: ${state.food!.protein.toInt()}g'),
            Text('Carboidratos: ${state.food!.carbs.toInt()}g'),
            Text('Gordura: ${state.food!.fat.toInt()}g'),
            Text(
              'Porção: ${state.food!.portion.toInt()}${state.food!.portionUnit}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _isProcessing = false;
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, state.food);
              _isProcessing = false;
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showNotFoundDialog(BuildContext context, String barcode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alimento não encontrado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código $barcode não está na base de dados.'),
            const SizedBox(height: 12),
            const Text(
              'Você pode inserir os dados nutricionais manualmente.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _isProcessing = false;
            },
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showManualEntryDialog();
            },
            child: const Text('Inserir manualmente'),
          ),
        ],
      ),
    );
  }
}
