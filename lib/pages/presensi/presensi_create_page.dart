import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; 
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http; 
import 'package:presensigps/services/api_service.dart';
import 'package:presensigps/utils/session_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:root_jailbreak_sniffer/rjsniffer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

class PresensiCreatePage extends StatefulWidget {
  final String ket; 
  const PresensiCreatePage({super.key, required this.ket});

  @override
  State<PresensiCreatePage> createState() => _PresensiCreatePageState();
}

class _PresensiCreatePageState extends State<PresensiCreatePage> {
  CameraController? _cameraController;
  Position? _currentPosition;
  bool _isCameraInitialized = false;
  bool _isSubmitting = false;
  bool _isInsideRadius = false;
  bool _isFakeGps = false;

  List<CircleMarker> _officeCircles = [];
  List<dynamic> _rawOfficeData = [];

  @override
  void initState() {
    super.initState();
    _initAllData();
  }

  Future<void> _initAllData() async {
    await _initializeCamera();
    
    await Future.wait([
      _determinePosition(),
      _fetchOfficeLocations(),
    ]);
  }

  void _checkRadius() {
    if (_currentPosition == null || _rawOfficeData.isEmpty) return;
    bool foundInside = false;
    for (var kantor in _rawOfficeData) {
      var coords = kantor['lokasi_kantor'].split(',');
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude, _currentPosition!.longitude,
        double.parse(coords[0]), double.parse(coords[1]),
      );
      if (distance <= double.parse(kantor['radius'].toString())) {
        foundInside = true;
        break;
      }
    }
    if (mounted) setState(() => _isInsideRadius = foundInside);
  }

  Future<void> _initializeCamera() async {
    try {
      if (_cameraController != null) await _cameraController!.dispose();

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) _showSnackbar("Kamera tidak ditemukan di perangkat ini.");
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
      if (mounted) _showSnackbar("Error Kamera: $e");
    }
  }

  Future<void> _fetchOfficeLocations() async {
    var box = Hive.box('konfigurasi');
    
    void gambarRadius() {
      if (mounted) {
        setState(() {
          _officeCircles = _rawOfficeData.map((k) {
            var coords = k['lokasi_kantor'].split(',');
            return CircleMarker(
              point: LatLng(double.parse(coords[0]), double.parse(coords[1])),
              color: Colors.red.withValues(alpha: 0.3),
              borderStrokeWidth: 2,
              borderColor: Colors.red,
              useRadiusInMeter: true,
              radius: double.parse(k['radius'].toString()),
            );
          }).toList();
        });
      }
      _checkRadius();
    }

    var connectivityResult = await (Connectivity().checkConnectivity());
    bool isOffline = connectivityResult.contains(ConnectivityResult.none);

    if (isOffline) {
      debugPrint("📴 [OFFLINE] Membaca radius dari memori HP...");
      if (box.containsKey('lokasi_kantor_string')) {
        try {
          _rawOfficeData = jsonDecode(box.get('lokasi_kantor_string'));
          gambarRadius();
        } catch (e) { debugPrint("Gagal baca memori radius: $e"); }
      }
      return;
    }

    try {
      final responseBody = await ApiService.get("/api/konfigurasi-lokasi");
      final result = jsonDecode(responseBody);
      
      if (result['status'] == 'success') {
        _rawOfficeData = result['data'];
        box.put('lokasi_kantor_string', jsonEncode(_rawOfficeData));
        debugPrint("✅ [ONLINE] Radius kantor berhasil ditarik & disimpan!");
        gambarRadius();
      } else {
        throw Exception("Server API Error"); 
      }
    } catch (e) {
      debugPrint("⚠️ API Gagal, fallback ke memori HP: $e");
      if (box.containsKey('lokasi_kantor_string')) {
        _rawOfficeData = jsonDecode(box.get('lokasi_kantor_string'));
        gambarRadius();
      }
    }
  }

  Future<void> _determinePosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 7),
        );
      } catch (e) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) return;
      
      final Position validPosition = position; 
      
      if (mounted) {
        setState(() {
          _currentPosition = validPosition;
          if (validPosition.isMocked && validPosition.accuracy < 100) {
            _isFakeGps = true;
          } else {
            _isFakeGps = false;
          }
        });
        
        _checkRadius();

        var connectivityResult = await (Connectivity().checkConnectivity());
        bool isOffline = connectivityResult.contains(ConnectivityResult.none);
        String? email = await SessionManager.getEmail();

        if (_isFakeGps) {
          if (!isOffline) {
            await ApiService.laporKecurangan(email ?? 'Unknown', 'Fake_GPS', 'Tuyul GPS terdeteksi (Online).');
          } else {
            Hive.box('audit_offline').add({
              'email': email ?? 'Unknown',
              'tipe': 'Fake_GPS',
              'pesan': 'Terdeteksi Fake GPS saat Offline. Akurasi: ${validPosition.accuracy}'
            });
          }
          _showSnackbar("Peringatan! Lokasi palsu terdeteksi.");
        }

        bool isRooted = await Rjsniffer.amICompromised() ?? false;
        
        if (isRooted) {
          if (!isOffline) {
            await ApiService.laporKecurangan(email ?? 'Unknown', 'Jailbreak', 'Perangkat Root terdeteksi.');
          } else {
            Hive.box('audit_offline').add({
              'email': email ?? 'Unknown',
              'tipe': 'Jailbreak',
              'pesan': 'Perangkat Root terdeteksi saat Mode Pesawat (Offline).'
            });
          }
          _showSnackbar("Peringatan! Perangkat Anda telah di-Root/Jailbreak. Akses ditolak.");
          setState(() {
            _isFakeGps = true; 
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal GPS: $e");
    }
  }

  Future<void> _simpanPresensi() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showSnackbar("Kamera belum siap.");
      return;
    }
    if (_currentPosition == null) {
      _showSnackbar("Lokasi belum ditemukan.");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      bool isMock = false;
      try {
        isMock = _currentPosition!.isMocked; 
      } catch (e) { debugPrint("Gagal cek lokasi palsu: $e"); }

      if (isMock) {
        _showSnackbar("Akses Ditolak! Matikan aplikasi Fake GPS Anda.");
        setState(() => _isSubmitting = false);
        return;
      }

      XFile image = await _cameraController!.takePicture();
      String? token = await SessionManager.getToken();
      
      final String targetPath = image.path.replaceFirst('.jpg', '_kecil.jpg');
      var compressedFile = await FlutterImageCompress.compressAndGetFile(
        image.path, 
        targetPath,
        quality: 60,
        autoCorrectionAngle: true, 
        keepExif: false,
      );

      if (compressedFile == null) {
        setState(() => _isSubmitting = false);
        return;
      }

      Future<void> simpanKeLokal() async {
        debugPrint("==== 📴 MENYIMPAN KE LOKAL ====");
        var offlineBox = Hive.box('absen_offline'); 
        
        await offlineBox.add({
          'lokasi': "${_currentPosition!.latitude},${_currentPosition!.longitude}",
          'image_path': compressedFile.path, 
          'ket': widget.ket,
          'timestamp': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Jaringan bermasalah! Absen disimpan di HP dan akan dikirim otomatis nanti."),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
          Navigator.pop(context);
        }
      }

      var connectivityResult = await (Connectivity().checkConnectivity());
      bool isOffline = connectivityResult.contains(ConnectivityResult.none);

      if (isOffline) {
        await simpanKeLokal();
        setState(() => _isSubmitting = false);
        return;
      }

      try {
        var uri = Uri.parse("${ApiService.baseUrl}/api/presensi/store");
        var request = http.MultipartRequest("POST", uri);
        
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        request.headers['Accept'] = 'application/json';
        
        request.fields['ket'] = widget.ket;
        request.fields['lokasi'] = "${_currentPosition!.latitude},${_currentPosition!.longitude}";
        request.files.add(await http.MultipartFile.fromPath('image', compressedFile.path));

        var response = await request.send().timeout(const Duration(seconds: 10));
        var responseData = await response.stream.bytesToString();

        if (!mounted) return;

        if (response.statusCode != 200) {
          String rawError = responseData.length > 100 ? "${responseData.substring(0, 100)}..." : responseData;
          _showSnackbar("ERROR SERVER ${response.statusCode}: \n$rawError");
          return; 
        }

        List<String> resultSplit = responseData.split('|');

        if (resultSplit.isNotEmpty) {
          if (resultSplit[0] == 'success') {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(resultSplit[1]), backgroundColor: Colors.green),
             );
             Navigator.pop(context); 
          } else {
             String errorMessage = resultSplit.length > 1 ? resultSplit[1] : responseData;
             _showSnackbar(errorMessage);
          }
        }
      } catch (e) {
        debugPrint("Timeout/Error koneksi saat mengirim: $e");
        await simpanKeLokal();
      }

    } catch (e) {
      if (mounted) _showSnackbar("Terjadi kesalahan: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Presensi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A234E),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  color: Colors.black,
                  child: _isCameraInitialized
                      ? CameraPreview(_cameraController!)
                      : const Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
              ),
              Expanded(
                flex: 1,
                child: _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          initialZoom: 16,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.presensigps',
                            tileProvider: CancellableNetworkTileProvider(),
                          ),
                          CircleLayer(circles: _officeCircles),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                width: 40, height: 40,
                                child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),

          if (_isFakeGps)
            Positioned(
              bottom: (MediaQuery.of(context).size.height / 3) + 45,
              left: 20, right: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade800,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)
                  ]
                ),
                child: const Text(
                  "Akses Ditolak!\nFake GPS (Lokasi Palsu) Terdeteksi.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          Positioned(
            bottom: (MediaQuery.of(context).size.height / 3) - 35,
            left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onTap: (_isSubmitting || _isFakeGps) ? null : () {
                  if (!_isInsideRadius) {
                    _showSnackbar("Maaf, Anda berada di luar radius kantor!");
                  } else {
                    _simpanPresensi();
                  }
                },
                child: Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isFakeGps ? Colors.grey.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.3),
                    border: Border.all(
                      color: _isFakeGps ? Colors.grey : (_isInsideRadius ? Colors.white : Colors.red), 
                      width: 3
                    ),
                  ),
                  child: _isSubmitting 
                    ? const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Icon(
                        _isFakeGps ? Icons.lock : Icons.camera_alt_outlined, 
                        color: _isFakeGps ? Colors.grey.shade300 : Colors.white, 
                        size: 35
                      ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}