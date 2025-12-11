class Departemen {
  final String kodeDept;
  final String namaDept;

  Departemen({required this.kodeDept, required this.namaDept});

  factory Departemen.fromJson(Map<String, dynamic> json) {
    return Departemen(
      kodeDept: json['kode_dept'] as String,
      namaDept: json['nama_dept'] as String,
    );
  }
}