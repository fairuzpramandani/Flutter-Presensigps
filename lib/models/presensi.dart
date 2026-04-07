class Presensi {
  final int id;
  final String nik;
  final String tglPresensi;
  final String? jamIn;
  final String? jamOut;
  final String? fotoIn;
  final String? fotoOut;
  final String? lokasiIn;
  final String? lokasiOut;

  Presensi({
    required this.id,
    required this.nik,
    required this.tglPresensi,
    this.jamIn,
    this.jamOut,
    this.fotoIn,
    this.fotoOut,
    this.lokasiIn,
    this.lokasiOut,
  });

  factory Presensi.fromJson(Map<String, dynamic> json) {
    return Presensi(
      id: json['id'] as int,
      nik: json['nik'] as String,
      tglPresensi: json['tgl_presensi'] as String,
      jamIn: json['jam_in'] as String?,
      jamOut: json['jam_out'] as String?,
      fotoIn: json['foto_in'] as String?,
      fotoOut: json['foto_out'] as String?,
      lokasiIn: json['lokasi_in'] as String?,
      lokasiOut: json['lokasi_out'] as String?,
    );
  }
}