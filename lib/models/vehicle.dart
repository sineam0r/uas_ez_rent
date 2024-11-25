class Vehicle {
  final String id;
  final String nama;
  final String brand;
  final String imageUrl;
  final double tarif;
  final String type;
  final bool isAvailable;
  final String deskripsi;
  final String transmisi;
  final int kapasitas;
  bool isFavorite;

  Vehicle({
    required this.id,
    required this.nama,
    required this.brand,
    required this.imageUrl,
    required this.tarif,
    required this.type,
    this.isAvailable = true,
    required this.deskripsi,
    required this.transmisi,
    required this.kapasitas,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'brand': brand,
      'imageUrl': imageUrl,
      'tarif': tarif,
      'type': type,
      'isAvailable': isAvailable,
      'deskripsi': deskripsi,
      'transmisi': transmisi,
      'kapasitas': kapasitas,
    };
  }

  static Vehicle fromMap(Map<String, dynamic> map, {bool isFavorite = false}) {
    return Vehicle(
      id: map['id'],
      nama: map['nama'],
      brand: map['brand'],
      imageUrl: map['imageUrl'],
      tarif: map['tarif'],
      type: map['type'],
      isAvailable: map['isAvailable'],
      deskripsi: map['deskripsi'],
      transmisi: map['transmisi'],
      kapasitas: map['kapasitas'],
      isFavorite: isFavorite,
    );
  }
}