import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presensigps/services/api_service.dart';
import 'package:presensigps/utils/session_manager.dart';

class HistoriPage extends StatefulWidget {
  const HistoriPage({super.key});

  @override
  State<HistoriPage> createState() => _HistoriPageState();
}

class _HistoriPageState extends State<HistoriPage> {
  final List<String> _bulanList = [
    "Januari", "Februari", "Maret", "April", "Mei", "Juni", 
    "Juli", "Agustus", "September", "Oktober", "November", "Desember"
  ];
  String? _selectedBulan;
  String? _selectedTahun;
  List<dynamic> _historiList = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _userPhotoUrl;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _selectedBulan = (now.month).toString();
    _selectedTahun = now.year.toString();
    _loadUserProfile();
  }

  // Ambil foto profil dari Session/API Profile
  Future<void> _loadUserProfile() async {
    String? email = await SessionManager.getEmail();
    if (email != null) {
      final result = await ApiService.getProfile(email);
      if (result['status'] == true) {
        setState(() {
          String photoName = result['data']['foto'] ?? 'default.png';
          _userPhotoUrl = "${ApiService.baseUrl}/storage/uploads/karyawan/$photoName";
        });
      }
    }
  }

  Future<void> _searchHistori() async {
    if (_selectedBulan == null || _selectedTahun == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih Bulan dan Tahun terlebih dahulu!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _historiList = [];
    });

    final result = await ApiService.getHistori(_selectedBulan!, _selectedTahun!);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['status'] == 'success') {
          _historiList = result['data'];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? "Gagal memuat data")),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
        ),
        title: const Text("Histori Presensi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A234E),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- BAGIAN FILTER ---
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedBulan,
                        decoration: const InputDecoration(
                          labelText: "Bulan",
                          prefixIcon: Icon(Icons.calendar_month),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        items: List.generate(12, (index) {
                          return DropdownMenuItem(
                            value: (index + 1).toString(),
                            child: Text(_bulanList[index]),
                          );
                        }),
                        onChanged: (val) => setState(() => _selectedBulan = val),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedTahun,
                        decoration: const InputDecoration(
                          labelText: "Tahun",
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        items: List.generate(5, (index) {
                          int year = 2024 + index;
                          return DropdownMenuItem(
                            value: year.toString(),
                            child: Text(year.toString()),
                          );
                        }),
                        onChanged: (val) => setState(() => _selectedTahun = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A234E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isLoading ? null : _searchHistori,
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Cari Data", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                  ),
                ),
              ],
            ),
          ),

          // --- BAGIAN LIST HISTORI ---
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : _historiList.isEmpty 
                ? Center(child: Text(_hasSearched ? "Data tidak ditemukan" : "Silakan cari data"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: _historiList.length,
                    itemBuilder: (context, index) {
                      var h = _historiList[index];
                      
                      String tgl = "";
                      try {
                        tgl = DateFormat("dd MMMM yyyy", "id_ID").format(DateTime.parse(h['tgl_presensi']));
                      } catch (e) {
                        tgl = h['tgl_presensi'];
                      }
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Foto Profil
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _userPhotoUrl != null 
                                    ? NetworkImage(_userPhotoUrl!) 
                                    : null,
                                child: _userPhotoUrl == null 
                                    ? const Icon(Icons.person, color: Colors.grey) 
                                    : null,
                              ),
                              
                              const SizedBox(width: 15),
                              
                              // Data Presensi
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tgl,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        _buildJamBadge(h['jam_in'], Colors.green, "Masuk"),
                                        const SizedBox(width: 8),
                                        _buildJamBadge(h['jam_out'], Colors.red, "Pulang"),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildJamBadge(String? jam, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color),
      ),
      child: Text(
        "$label: ${jam ?? '--:--'}", 
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)
      ),
    );
  }
}