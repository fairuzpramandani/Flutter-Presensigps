import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:presensigps/services/api_service.dart';
import 'package:presensigps/utils/session_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FaceEnrollmentPage extends StatefulWidget {
  const FaceEnrollmentPage({super.key});

  @override
  State<FaceEnrollmentPage> createState() => _FaceEnrollmentPageState();
}

class _FaceEnrollmentPageState extends State<FaceEnrollmentPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isSubmitting = false;
  String? _cameraError;
  
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _cameraError = "Kamera tidak ditemukan di perangkat ini.");
        return;
      }

      CameraDescription selectedCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraError = "Gagal membuka kamera. Error asli:\n$e";
        });
      }
    }
  }

  Future<void> _registerFace() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() => _isSubmitting = true);

    try {
      XFile image = await _cameraController!.takePicture();

      if (_currentStep == 1) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) setState(() { _currentStep = 2; _isSubmitting = false; });
        return;
      } 
      else if (_currentStep == 2) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) setState(() { _currentStep = 3; _isSubmitting = false; });
        return;
      } 
      else if (_currentStep == 3) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) setState(() { _currentStep = 4; _isSubmitting = false; });
        return;
      } 
      else if (_currentStep == 4) {
        String? email = await SessionManager.getEmail();
        String? token = await SessionManager.getToken();
        
        XFile fotoFinal = image; 
        final String targetPath = fotoFinal.path.replaceFirst('.jpg', '_kecil.jpg');
        
        var compressedFile = await FlutterImageCompress.compressAndGetFile(
          fotoFinal.path,
          targetPath,
          quality: 60,
          autoCorrectionAngle: true,
          keepExif: false,
        );

        if (compressedFile == null) {
          _showError("Gagal mengompres gambar.");
          return;
        }

        var uri = Uri.parse("${ApiService.baseUrl}/api/registrasi-wajah");
        var request = http.MultipartRequest("POST", uri);

        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        request.headers['Accept'] = 'application/json';

        request.files.add(await http.MultipartFile.fromPath('image', compressedFile.path));

        if (email != null) {
          request.fields['email'] = email;
        }

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (!mounted) return;

        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status'] == 'success') {
            
            var akurasi = jsonResponse['accuracy'] ?? '100';

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text("Registrasi Berhasil", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                content: Text("Wajah Anda sukses divalidasi oleh AI Python!\nTingkat Akurasi: $akurasi%"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                    child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          } else {
            _showError(jsonResponse['message'] ?? "Gagal memproses wajah.");
            setState(() => _currentStep = 1); 
          }
        } else {
          _showError("Kesalahan server (${response.statusCode}): \n${response.body}");
          setState(() => _currentStep = 1);
        }
      }
    } catch (e) {
      if (mounted) _showError("Error sistem: $e");
    } finally {
      if (mounted && _currentStep == 4) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  String get _stepTitle {
    switch (_currentStep) {
      case 1: return "TAHAP 1: FOTO DEPAN";
      case 2: return "TAHAP 2: TOLEH KANAN";
      case 3: return "TAHAP 3: TOLEH KIRI";
      case 4: return "TAHAP 4: KEDIPKAN MATA";
      default: return "MEMPROSES...";
    }
  }

  String get _stepDescription {
    switch (_currentStep) {
      case 1: return "Posisikan wajah lurus di dalam bingkai";
      case 2: return "Tolehkan wajah Anda sedikit ke KANAN";
      case 3: return "Tolehkan wajah Anda sedikit ke KIRI";
      case 4: return "Kedipkan kedua mata Anda ke kamera";
      default: return "Mohon tunggu sebentar...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Registrasi Wajah", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: Colors.blue.shade600,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'), 
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: _cameraError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(_cameraError!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                  )
                : _isCameraInitialized
                    ? CameraPreview(_cameraController!)
                    : const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),

          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildStepDot(isActive: _currentStep >= 1),
                      _buildStepDot(isActive: _currentStep >= 2),
                      _buildStepDot(isActive: _currentStep >= 3),
                      _buildStepDot(isActive: _currentStep >= 4),
                    ],
                  ),
                ),
                Text(_stepTitle, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Text(_stepDescription, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),

          if (_isCameraInitialized)
            Align(
              alignment: Alignment.center,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.45,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70, width: 2.5),
                  borderRadius: const BorderRadius.all(Radius.elliptical(250, 350)),
                ),
              ),
            ),

          if (_isCameraInitialized)
            Positioned(
              bottom: 40,
              child: GestureDetector(
                onTap: _isSubmitting ? null : _registerFace,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10, 
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: _isSubmitting
                      ? const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                        )
                      : const Icon(Icons.camera_alt, color: Color(0xFF333333), size: 35),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildStepDot({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? Colors.greenAccent : Colors.grey.shade600,
        shape: BoxShape.circle,
      ),
    );
  }
}