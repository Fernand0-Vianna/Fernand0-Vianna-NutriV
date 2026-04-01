import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceInputWidget extends StatefulWidget {
  final Function(String) onTextRecognized;

  const VoiceInputWidget({super.key, required this.onTextRecognized});

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _isAvailable = await _speechToText.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }

  void _startListening() async {
    if (_isAvailable) {
      setState(() {
        _isListening = true;
        _recognizedText = '';
      });
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
          if (result.finalResult) {
            setState(() => _isListening = false);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'pt_BR',
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reconhecimento de voz não disponível')),
        );
      }
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Entrada por Voz'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            size: 64,
            color: _isListening ? Colors.red : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _isListening
                ? 'Ouvindo... Fale agora'
                : 'Toque no microfone para falar',
            textAlign: TextAlign.center,
          ),
          if (_recognizedText.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _recognizedText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        if (_recognizedText.isNotEmpty)
          ElevatedButton(
            onPressed: () {
              widget.onTextRecognized(_recognizedText);
              Navigator.pop(context);
            },
            child: const Text('Buscar'),
          ),
        ElevatedButton.icon(
          onPressed: _isListening ? _stopListening : _startListening,
          icon: Icon(_isListening ? Icons.stop : Icons.mic),
          label: Text(_isListening ? 'Parar' : 'Iniciar'),
        ),
      ],
    );
  }
}
