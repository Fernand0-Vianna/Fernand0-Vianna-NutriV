import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../bloc/barcode/barcode_scanner_bloc.dart';
import '../../bloc/barcode/barcode_scanner_event.dart';
import '../../bloc/barcode/barcode_scanner_state.dart';

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
            ],
          );
        },
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
        content: Text('Código $barcode não está na base de dados.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _isProcessing = false;
            },
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
