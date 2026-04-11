import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presensigps/services/api_service.dart';
import 'package:presensigps/pages/izin/buat_izin_page.dart';

class IzinPage extends StatefulWidget {
  const IzinPage({super.key});

  @override
  State<IzinPage> createState() => _IzinPageState();
}

class _IzinPageState extends State<IzinPage> {
  List<dynamic> _dataIzin = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Panggil fungsi yang baru kita buat di ApiService
    final result = await ApiService.getIzinList();
    
    if (mounted) {
      setState(() {
        if (result['status'] == 'success') {
          _dataIzin = result['data'];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Data Izin & Sakit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A234E), // Sesuaikan warna Blade
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dataIzin.isEmpty
              ? const Center(child: Text("Belum ada data pengajuan izin"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: _dataIzin.length,
                  itemBuilder: (context, index) {
                    var d = _dataIzin[index];
                    
                    // Format Tanggal (Contoh: 12 Januari 2024)
                    String formattedDate = "";
                    try {
                      formattedDate = DateFormat("d MMMM yyyy", "id_ID").format(DateTime.parse(d['tgl_izin']));
                    } catch (e) {
                      formattedDate = d['tgl_izin']; // Fallback jika format gagal
                    }

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Tampilkan Tanggal & Status (Sakit/Izin)
                                Text(
                                  "$formattedDate (${d['status'] == 's' ? 'Sakit' : 'Izin'})",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                // Badge Status Approval
                                _buildStatusBadge(d['status_approved']),
                              ],
                            ),
                            const Divider(),
                            Text(
                              d['keterangan'] ?? "Tidak ada keterangan",
                              style: TextStyle(color: Colors.grey[700], fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A234E),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Buka halaman form, lalu refresh data saat kembali
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BuatIzinPage()),
          );
          setState(() => _isLoading = true);
          _fetchData();
        },
      ),
    );
  }

  // Widget kecil untuk badge status (Menunggu, Disetujui, Ditolak)
  Widget _buildStatusBadge(dynamic status) {
    Color color;
    String text;
    // Konversi ke int agar aman
    int s = int.tryParse(status.toString()) ?? 0;

    if (s == 1) {
      color = Colors.green;
      text = "Disetujui";
    } else if (s == 2) {
      color = Colors.red;
      text = "Ditolak";
    } else {
      color = Colors.orange;
      text = "Menunggu";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}