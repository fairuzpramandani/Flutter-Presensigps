class JamKerja {
  final String kodeJamKerja;
  final String namaJamKerja;
  final String jamMasuk;
  final String jamPulang;

  JamKerja({
    required this.kodeJamKerja,
    required this.namaJamKerja,
    required this.jamMasuk,
    required this.jamPulang,
  });

  factory JamKerja.fromJson(Map<String, dynamic> json) {
    return JamKerja(
      kodeJamKerja: json['kode_jam_kerja'] ?? '',
      namaJamKerja: json['nama_jam_kerja'] ?? '',
      jamMasuk: json['jam_masuk'] ?? '',
      jamPulang: json['jam_pulang'] ?? '',
    );
  }
}