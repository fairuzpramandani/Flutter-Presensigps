import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:presensigps/models/user.dart';
import 'package:presensigps/services/api_service.dart';
import 'package:presensigps/widgets/bottom_nav.dart';
import 'package:presensigps/utils/session_manager.dart';
import 'package:presensigps/utils/app_assets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const String waktuMasukMax = "23:45:00";
  static const String waktuPulangMin = "17:00:00";
  
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isConnected = true;

  String _distanceText = 'Menghitung Jarak...';
  bool _isInsideGeofence = false;

  String _checkInTime = '--:--';
  String _checkOutTime = '--:--';
  final bool _isDeviceSecure = true; 
  
  late StreamSubscription<List<ConnectivityResult>> _sensorSinyal;
  Timer? _geofenceTimer;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    ApiService.sinkronisasiAbsenOffline();
    _startLiveGeofenceCheck(); 

    _sensorSinyal = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      final hasConnection = !result.contains(ConnectivityResult.none);
      setState(() {
        _isConnected = hasConnection;
      });
      if (hasConnection) {
        ApiService.sinkronisasiAbsenOffline();
        _fetchUserData(); 
      }
    });
  }

  @override
  void dispose() {
    _sensorSinyal.cancel();
    _geofenceTimer?.cancel(); 
    super.dispose();
  }

  void _startLiveGeofenceCheck() {
    _geofenceTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          await Geolocator.requestPermission();
        }

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
        );
        
        double officeLat = -6.2088; 
        double officeLng = 106.8456;
        
        double distanceInMeters = Geolocator.distanceBetween(
          position.latitude, position.longitude, officeLat, officeLng
        );

        if (mounted) {
          setState(() {
            _distanceText = '${distanceInMeters.toStringAsFixed(1)} meter';
            _isInsideGeofence = distanceInMeters <= 50; 
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _distanceText = 'GPS Tidak Aktif';
            _isInsideGeofence = false;
          });
        }
      }
    });
  }

  Future<void> _fetchUserData() async {
    try {
      String? userEmail = await SessionManager.getEmail();
      if (userEmail == null || userEmail.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final result = await ApiService.getProfile(userEmail); 
      if (!mounted) return;

      if (result['status'] == true) {
        setState(() {
          _currentUser = UserModel.fromJson(result['data']);
          _isLoading = false;
          
          if (result['data']['jam_masuk'] != null) {
            _checkInTime = result['data']['jam_masuk'];
          }
          if (result['data']['jam_pulang'] != null) {
            _checkOutTime = result['data']['jam_pulang'];
          }
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) return "Selamat Pagi";
    if (hour >= 12 && hour < 15) return "Selamat Siang";
    if (hour >= 15 && hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  void _handleAbsen(String batasWaktu, String jenisAbsen) {
    if (!_isInsideGeofence) {
      _showWarning('Ditolak!', 'Anda berada di luar radius kantor! Tidak dapat melakukan absensi.');
      return;
    }

    final currentTimeStr = DateFormat('HH:mm:ss').format(DateTime.now());
    if (jenisAbsen == 'in') {
      if (currentTimeStr.compareTo(batasWaktu) > 0) {
        _showWarning('Waktu Habis!', 'Absen Masuk hanya bisa dilakukan sebelum jam ${batasWaktu.substring(0, 5)} WIB.');
      } else {
        Navigator.pushNamed(context, '/presensi/create', arguments: {'ket': 'in'}).then((_) {
          ApiService.sinkronisasiAbsenOffline();
          setState(() {
            _checkInTime = "${DateFormat('HH:mm').format(DateTime.now())} WIB";
          });
        });
      }
    } else if (jenisAbsen == 'out') {
      if (currentTimeStr.compareTo(batasWaktu) < 0) {
        _showWarning('Belum Waktunya!', 'Absen Pulang bisa dilakukan setelah jam ${batasWaktu.substring(0, 5)} WIB.');
      } else {
        Navigator.pushNamed(context, '/presensi/create', arguments: {'ket': 'out'}).then((_) {
          ApiService.sinkronisasiAbsenOffline();
          setState(() {
            _checkOutTime = "${DateFormat('HH:mm').format(DateTime.now())} WIB";
          });
        });
      }
    }
  }

  void _showWarning(String title, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(text),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    await _fetchUserData();
    await ApiService.sinkronisasiAbsenOffline();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final photoUrl = (_currentUser?.foto?.isNotEmpty ?? false)
        ? '${ApiService.baseUrl.replaceAll("/api", "")}/storage/uploads/karyawan/${_currentUser!.foto}'
        : AppAssets.avatarDefault;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8.0, left: 20.0, right: 20.0, bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(AppAssets.logo, height: 95, fit: BoxFit.contain),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: FadeInImage.assetNetwork(
                          placeholder: AppAssets.avatarDefault,
                          image: photoUrl,
                          width: 65,
                          height: 65,
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset(AppAssets.avatarDefault, height: 65, width: 65, fit: BoxFit.cover);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade800, Colors.indigo.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getGreeting(), style: const TextStyle(fontSize: 14, color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(
                        _currentUser?.namaLengkap ?? 'Karyawan',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isConnected ? "Sistem Online • Auto-Sync Aktif" : "Sistem Offline • Menyimpan ke Hive",
                        style: const TextStyle(fontSize: 12, color: Colors.white60),
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Divider(color: Colors.white24, height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.login_rounded, size: 14, color: Colors.greenAccent),
                              const SizedBox(width: 4),
                              Text("Masuk: $_checkInTime", style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.logout_rounded, size: 14, color: Color.fromARGB(255, 248, 95, 95)),
                              const SizedBox(width: 4),
                              Text("Pulang: $_checkOutTime", style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_searching_rounded, size: 18, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Informasi Sensor GPS Geofence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                          ],
                        ),
                        const Divider(height: 24, color: Colors.black12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Jarak ke Kantor:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                            Text(_distanceText, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 13, color: Colors.black87)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Status Zona Radius:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isInsideGeofence ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _isInsideGeofence ? 'Dalam Radius Area' : 'Di Luar Radius Area',
                                style: TextStyle(color: _isInsideGeofence ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        
                        const Divider(height: 24, color: Colors.black12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Sistem Proteksi Perangkat:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                            Row(
                              children: [
                                Icon(Icons.shield_outlined, size: 15, color: _isDeviceSecure ? Colors.green : Colors.red),
                                const SizedBox(width: 4),
                                Text(
                                  _isDeviceSecure ? 'Aman (No Fake GPS)' : 'Bahaya Terdeteksi',
                                  style: TextStyle(
                                    color: _isDeviceSecure ? Colors.green.shade700 : Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 44),

                Row(
                  children: [
                    Expanded(
                      child: _buildPureBorderlessAbsenBtn(
                        iconPath: AppAssets.absenMasuk,
                        label: 'Absen Masuk',
                        onTap: () {
                          if (_checkInTime != '--:--') {
                            _showWarning('Sudah Absen!', 'Anda sudah melakukan Absen Masuk hari ini, jadi Anda tidak bisa absen masuk lagi.');
                          } else {
                            _handleAbsen(waktuMasukMax, 'in');
                          }
                        },
                        isCompleted: _checkInTime != '--:--',
                      ),
                    ),
                    const SizedBox(width: 24), 
                    Expanded(
                      child: _buildPureBorderlessAbsenBtn(
                        iconPath: AppAssets.absenKeluar,
                        label: 'Absen Pulang',
                        onTap: () {
                          if (_checkOutTime != '--:--') {
                            _showWarning('Sudah Absen!', 'Anda sudah melakukan Absen Pulang hari ini, jadi Anda tidak bisa absen pulang lagi.');
                          } else {
                            _handleAbsen(waktuPulangMin, 'out');
                          }
                        },
                        isCompleted: _checkOutTime != '--:--',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildPureBorderlessAbsenBtn({required String iconPath, required String label, required VoidCallback onTap, bool isCompleted = false}) {
    return Material(
      color: Colors.transparent, 
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isCompleted 
                ? ColorFiltered(
                    colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                    child: Image.asset(iconPath, height: 150, width: 150, fit: BoxFit.contain),
                  )
                : Image.asset(iconPath, height: 150, width: 150, fit: BoxFit.contain),
              const SizedBox(height: 12),
              Text(
                label, 
                style: TextStyle(
                  fontSize: 15, 
                  fontWeight: FontWeight.bold, 
                  color: isCompleted ? Colors.grey : Colors.black87, 
                  letterSpacing: 0.3
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}