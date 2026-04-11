import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presensigps/services/api_service.dart';

class BuatIzinPage extends StatefulWidget {
  const BuatIzinPage({super.key});

  @override
  State<BuatIzinPage> createState() => _BuatIzinPageState();
}

class _BuatIzinPageState extends State<BuatIzinPage> {
  final TextEditingController _tglController = TextEditingController();
  final TextEditingController _ketController = TextEditingController();
  String? _selectedStatus; 
  bool _isSubmitting = false;
  File? _buktiFoto; // Variabel untuk menyimpan foto bukti sakit

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), 
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tglController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // FUNGSI: Ambil Foto dari Galeri/Kamera
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image != null) {
      setState(() {
        _buktiFoto = File(image.path);
      });
    }
  }

  Future<void> _submitIzin() async {
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
    
    // Validasi Wajib Foto jika Status = Sakit (s)
    if (_selectedStatus == 's' && _buktiFoto == null) {
      _showSnackbar("Wajib melampirkan foto Surat Dokter/Bukti Sakit!", Colors.red);
      return;
    }

    setState(() => _isSubmitting = true);

    // Kirim menggunakan ApiService khusus Multipart
    final result = await ApiService.storeIzinWithFile(
      _tglController.text,
      _selectedStatus!,
      _ketController.text,
      _buktiFoto, 
    );

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil mengirim pengajuan!")),
        );
        Navigator.pop(context); 
      } else {
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
            
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _tglController,
                      readOnly: true, 
                      onTap: () => _selectDate(context),
                      decoration: const InputDecoration(
                        labelText: "Tanggal",
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus, // Perbaikan linter (initialValue bukan value)
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
                        setState(() {
                          _selectedStatus = val;
                          // Reset foto jika user ganti pikiran jadi Izin
                          if (val == 'i') _buktiFoto = null; 
                        });
                      },
                    ),
                    const SizedBox(height: 20),

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
                    const SizedBox(height: 20),

                    // TAMPILKAN TOMBOL UPLOAD JIKA STATUS == 's'
                    if (_selectedStatus == 's') ...[
                      const Text("Bukti Sakit (Surat Dokter)", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[100],
                          ),
                          child: _buktiFoto != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(_buktiFoto!, fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text("Ketuk untuk Upload Foto", style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],

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