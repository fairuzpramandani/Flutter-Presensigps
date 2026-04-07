import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presensigps/services/api_service.dart';

class BuatIzinPage extends StatefulWidget {
  const BuatIzinPage({super.key});

  @override
  State<BuatIzinPage> createState() => _BuatIzinPageState();
}

class _BuatIzinPageState extends State<BuatIzinPage> {
  final TextEditingController _tglController = TextEditingController();
  final TextEditingController _ketController = TextEditingController();
  String? _selectedStatus; // Menyimpan nilai 'i' atau 's'
  bool _isSubmitting = false;

  // Fungsi memunculkan DatePicker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Tidak boleh tanggal kemarin
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tglController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Fungsi Kirim Data
  Future<void> _submitIzin() async {
    // Validasi Input (Sama seperti JS di Blade)
    if (_tglController.text.isEmpty) {
      _showSnackbar("Tanggal harus diisi!", Colors.orange);
      return;
    }
    if (_selectedStatus == null) {
      _showSnackbar("Status harus dipilih!", Colors.orange);
      return;
    }
    if (_ketController.text.isEmpty) {
      _showSnackbar("Keterangan harus diisi!", Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);

    // Panggil ApiService
    final result = await ApiService.storeIzin(
      _tglController.text,
      _selectedStatus!,
      _ketController.text
    );

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (result['status'] == 'success') {
        // Jika Sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil mengirim pengajuan!")),
        );
        Navigator.pop(context); // Kembali ke list
      } else {
        // Jika Gagal (Misal tanggal duplikat)
        _showSnackbar(result['message'] ?? "Gagal menyimpan data", Colors.red);
      }
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
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
        title: const Text("Form Izin & Sakit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A234E),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Formulir Pengajuan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            // Card Container
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // INPUT TANGGAL
                    TextField(
                      controller: _tglController,
                      readOnly: true, // Agar tidak bisa diketik manual
                      onTap: () => _selectDate(context),
                      decoration: const InputDecoration(
                        labelText: "Tanggal",
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // INPUT STATUS (Dropdown)
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: "Status",
                        prefixIcon: Icon(Icons.info_outline),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "i", child: Text("Izin")),
                        DropdownMenuItem(value: "s", child: Text("Sakit")),
                      ],
                      onChanged: (val) {
                        setState(() => _selectedStatus = val);
                      },
                    ),
                    const SizedBox(height: 20),

                    // INPUT KETERANGAN
                    TextField(
                      controller: _ketController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Keterangan",
                        hintText: "Tulis alasan Anda...",
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.edit_note),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // TOMBOL KIRIM
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A234E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _isSubmitting ? null : _submitIzin,
                        child: _isSubmitting 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Kirim Pengajuan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}