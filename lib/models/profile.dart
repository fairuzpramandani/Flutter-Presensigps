class Profile {
  final String email;
  final String namaLengkap;
  final String jabatan;
  final String? noHp;
  final String? kodeDept;
  final String? foto;

  Profile({
    required this.email,
    required this.namaLengkap,
    required this.jabatan,
    this.noHp,
    this.kodeDept,
    this.foto,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      email: json['email'] as String,
      namaLengkap: json['nama_lengkap'] as String,
      jabatan: json['jabatan'] as String,
      noHp: json['no_hp'] as String?,
      kodeDept: json['kode_dept'] as String?,
      foto: json['foto'] as String?,
    );
  }
}