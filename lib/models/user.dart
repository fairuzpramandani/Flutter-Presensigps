class UserModel {
  final String? email;
  final String? namaLengkap;
  final String? jabatan;
  final String? noHp;
  final String? foto;
  final String? namaDept;

  UserModel({
    this.email,
    this.namaLengkap,
    this.jabatan,
    this.noHp,
    this.foto,
    this.namaDept,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email']?.toString(),
      namaLengkap: json['nama_lengkap']?.toString(),
      jabatan: json['jabatan']?.toString(),
      noHp: json['no_hp']?.toString(),
      foto: json['foto']?.toString(),
      namaDept: json['nama_dept']?.toString(), 
    );
  }
}