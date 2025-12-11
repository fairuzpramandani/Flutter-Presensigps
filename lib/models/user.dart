class UserModel {
  final String? email;
  final String? namaLengkap;
  final String? jabatan;
  final String? noHp;
  final String? foto;
  final String? namaDept;

  UserModel({
    required this.email,
    required this.namaLengkap,
    this.jabatan,
    this.noHp,
    this.foto,
    this.namaDept,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      namaLengkap: json['nama_lengkap'],
      jabatan: json['jabatan'],
      noHp: json['no_hp'],
      foto: json['foto'],
      namaDept: json['nama_dept'], 
    );
  }
}