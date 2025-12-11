class Izin {
  final int id;
  final String nik;
  final String tglIzin;
  final String status;
  final String keterangan;
  final String statusApproval;

  Izin({
    required this.id,
    required this.nik,
    required this.tglIzin,
    required this.status,
    required this.keterangan,
    required this.statusApproval,
  });

  factory Izin.fromJson(Map<String, dynamic> json) {
    return Izin(
      id: json['id'] as int,
      nik: json['nik'] as String,
      tglIzin: json['tgl_izin'] as String,
      status: json['status'] as String,
      keterangan: json['keterangan'] as String,
      statusApproval: json['status_approved'] as String,
    );
  }
}