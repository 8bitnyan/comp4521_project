import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;

  String _llmResponse = '';
  bool _isLoading = false;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      setState(() {
        _isLoading = true;
        _llmResponse = '';
      });

      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      setState(() {
        _capturedImage = image;
      });
      await _sendImageToLLM(image.path);
    } catch (e) {
      setState(() {
        _llmResponse = 'Error in taking photo: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendImageToLLM(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse(
        'https://hkust.azure-api.net/openai/deployments/gpt-4o-mini/chat/completions?api-version=2024-10-21',
      );

      final headers = {
        'Content-Type': 'application/json',
        'api-key': ' 1777ac2662f649a7bbc0c905d85eb7bd',
      };

      final body = jsonEncode({
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "type": "image_url",
                "image_url": {
                  "url": "data:image/jpeg;base64,$base64Image"
                }
              },
              {
                "type": "text",
                "text": "Explain me about this image."
              }
            ]
          }
        ],
        "temperature": 0.7,
        "top_p": 1,
        "stream": false,
        "max_tokens": 1000,
        "n": 1,
        "response_format": {"type": "text"}
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final reply = responseData['choices'][0]['message']['content'];

        setState(() {
          _llmResponse = reply;
          _isLoading = false;
        });
      } else {
        setState(() {
          _llmResponse = 'LLM Response Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _llmResponse = 'LLM Processing Error: $e';
        _isLoading = false;
      });
    }
  }

  void _resetToCamera() {
    setState(() {
      _capturedImage = null;
      _llmResponse = '';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: Column(
        children: [
          // 상단 영역
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Positioned.fill(
                  child: _capturedImage != null
                      ? Image.file(File(_capturedImage!.path), fit: BoxFit.cover)
                      : (_controller != null
                      ? FutureBuilder(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CameraPreview(_controller!);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                      : const Center(child: CircularProgressIndicator())),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _capturedImage == null
                        ? FloatingActionButton(
                      onPressed: _takePicture,
                      child: const Icon(Icons.camera_alt),
                    )
                        : ElevatedButton.icon(
                      onPressed: _resetToCamera,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retake'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 하단 영역
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[100],
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _llmResponse.isNotEmpty
                  ? SingleChildScrollView(
                child: Text(
                  _llmResponse,
                  style: const TextStyle(fontSize: 16),
                ),
              )
                  : const Center(
                child: Text(
                  'Explanation will be shown here when you take a photo.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
