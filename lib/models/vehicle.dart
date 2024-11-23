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
}