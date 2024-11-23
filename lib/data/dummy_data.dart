import 'package:uas_ez_rent/models/vehicle.dart';

final List<Vehicle> dummyVehicles = [
  Vehicle(
    id: '1',
    nama: 'Avanza',
    brand: 'Toyota',
    imageUrl: 'img/avanza.jpg',
    tarif: 300000,
    type: 'Mobil',
    deskripsi: 'Toyota Avanza 2022 dengan kondisi sangat baik',
    transmisi: 'Manual',
    kapasitas: 6
  ),
  Vehicle(
    id: '2',
    nama: 'Xpander',
    brand: 'Mitsubishi',
    imageUrl: 'img/xpander.jpg',
    tarif: 350000,
    type: 'Mobil',
    deskripsi: 'Mitsubishi Xpander Ultimate 2023',
    transmisi: 'Automatic',
    kapasitas: 6,
  ),
  Vehicle(
    id: '3',
    nama: 'PCX',
    brand: 'Honda',
    imageUrl: 'img/pcx.jpg',
    tarif: 150000,
    type: 'Motor',
    deskripsi: 'Honda PCX 160cc 2023',
    transmisi: 'Automatic',
    kapasitas: 2
  ),
  Vehicle(
    id: '4',
    nama: 'Nmax',
    brand: 'Yamaha',
    imageUrl: 'img/nmax.jpg',
    tarif: 150000,
    type: 'Motor',
    deskripsi: 'Yamaha Nmax 155cc 2023',
    transmisi: 'Automatic',
    kapasitas: 2
  ),
];