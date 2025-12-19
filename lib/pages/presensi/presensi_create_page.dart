import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:presensigps/services/api_service.dart';
import 'package:presensigps/utils/session_manager.dart';


class PresensiCreatePage extends StatefulWidget {
  // Argument 'ket' (in/out) dikirim dari DashboardPage
  final String ket; 

  const PresensiCreatePage({super.key, required this.ket});

  @override
  State<PresensiCreatePage> createState() => _PresensiCreatePageState();
}

class _PresensiCreatePageState extends State<PresensiCreatePage> {
  final _picker = ImagePicker();
  
  bool _isLoading = true;
  bool _isSending = false;
  String? _statusMessage;
  Position? _currentPosition;
  XFile? _imageFile; 
  final List<Map<String, dynamic>> _kantorList = const [
    {'lat': -6.1754, 'lng': 106.8272, 'radius': 50, 'name': 'Kantor Pusat'}, 
  ];


  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() => _isLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _statusMessage = 'Layanan lokasi dinonaktifkan. Mohon aktifkan GPS.';
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _statusMessage = 'Izin lokasi ditolak. Presensi tidak dapat dilakukan.';
        setState(() => _isLoading = false);
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      setState(() {
        _currentPosition = position;
        _statusMessage = "Lokasi terdeteksi! Siap untuk presensi.";
        _isLoading = false;
      });
      // Setelah lokasi didapat, langsung ambil foto
      _takePhoto(); 
      
    } catch (e) {
      _statusMessage = "Gagal mendapatkan lokasi. Coba lagi atau aktifkan GPS.";
      setState(() => _isLoading = false);
    }
  }

  // --- 2. Ambil Foto (Simulasi Webcam) ---
  Future<void> _takePhoto() async {
    // Menggunakan ImagePicker untuk mensimulasikan Webcam.snap()
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    } else {
      _statusMessage = "Pengambilan foto dibatalkan.";
      setState(() {});
    }
  }

  // --- 3. Pengecekan Radius & Pengiriman Data ---
  Future<void> _prosesPresensi() async {
    if (_currentPosition == null) {
      _showError('Error!', 'Lokasi belum terdeteksi.');
      return;
    }
    if (_imageFile == null) {
      _showError('Error!', 'Foto selfie wajib diambil.');
      return;
    }

    // Pengecekan Radius (Mirip Logic JavaScript)
    final double userLat = _currentPosition!.latitude;
    final double userLng = _currentPosition!.longitude;
    bool isInRange = false;
    
    // Asumsi Anda hanya perlu berada di dekat SALAH SATU kantor
    for (var kantor in _kantorList) {
      final double distanceInMeters = Geolocator.distanceBetween(
        userLat,
        userLng,
        kantor['lat'] as double,
        kantor['lng'] as double,
      );
      
      if (distanceInMeters <= (kantor['radius'] as int)) {
        isInRange = true;
        break; // Ditemukan satu kantor yang masuk radius
      }
    }

    if (!isInRange) {
      _showError('Jarak Terlalu Jauh', 'Anda berada di luar radius kantor yang diizinkan (Max: ${_kantorList.first['radius']} meter).');
      return;
    }
    
    // Logika pengiriman data ke Laravel
    setState(() => _isSending = true);

    // Convert foto ke Base64
    final fileBytes = await _imageFile!.readAsBytes();
    final imageBase64 = base64Encode(fileBytes);
    
    final token = await SessionManager.getToken();
    
    final data = {
      'lokasi': '$userLat,$userLng', 
      'image': imageBase64,
      // 'ket' tidak perlu dikirim jika Laravel menentukannya dari status presensi harian
      // Tapi jika Laravel memerlukannya: 'keterangan': widget.ket, 
    };

    final res = await ApiService.presensiStore(token!, data['lokasi'].toString(), data['image'].toString());

    if (!mounted) return;
    setState(() => _isSending = false);

    if (res['status'] == 'success') {
      _showSuccess('Sukses!', res['message'] ?? 'Presensi berhasil dicatat.');
      // Kembali ke dashboard setelah 3 detik (seperti setTimeout di JS)
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
        }
      });
    } else {
      _showError('Gagal Presensi', res['message'] ?? 'Presensi gagal. Coba lagi.');
    }
  }
  
  void _showError(String title, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: $text'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String title, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: $text'),
        backgroundColor: Colors.green,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final bool isAbsenPulang = widget.ket == 'out';
    
    // Judul sesuai Absen Masuk/Pulang
    final String pageTitle = isAbsenPulang ? 'Absen Pulang' : 'Absen Masuk';
    final String buttonText = isAbsenPulang ? 'ABSEN PULANG' : 'ABSEN MASUK';
    final Color buttonColor = isAbsenPulang ? Colors.red : const Color(0xFF0A234E); // Sesuai warna di Blade

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        backgroundColor: const Color(0xFF0A234E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Webcam Capture (Simulasi) ---
            Container(
              height: 350,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
              ),
              child: _buildCameraWidget(),
            ),
            const SizedBox(height: 20),

            // --- Lokasi dan Status ---
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Status Lokasi'),
                subtitle: Text(
                  _isLoading 
                    ? 'Mencari lokasi...' 
                    : (_currentPosition != null 
                        ? 'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}'
                        : (_statusMessage ?? 'Gagal mendapatkan GPS.')
                      ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // --- Map Placeholder ---
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: _currentPosition == null
                    ? const Text('Map Placeholder: Tunggu GPS...')
                    : Text('GPS Ditemukan.\nRadius Check: ${_kantorList.first['name']} (${_kantorList.first['radius']}m)'),
              ),
            ),
            const SizedBox(height: 20),
            
            // --- Tombol Absen ---
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isSending || _isLoading ? null : _prosesPresensi,
                icon: _isSending 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Icon(Icons.camera_alt_outlined),
                label: Text(buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCameraWidget() {
    if (_imageFile != null) {
      return Image.file(
        File(_imageFile!.path),
        fit: BoxFit.cover,
      );
    }
    if (_isLoading) {
      return const Center(child: Text('Meminta Akses Lokasi & Kamera...'));
    }
    return const Center(child: Text('Kamera Siap. Klik tombol ABSEN.'));
  }
}