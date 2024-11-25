import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_ez_rent/models/vehicle.dart';
import 'package:uas_ez_rent/providers/favorite_provider.dart';
import 'package:uas_ez_rent/screens/form_screen.dart';

class DetailsScreen extends StatefulWidget {
  final Vehicle vehicle;

  const DetailsScreen({
    required this.vehicle,super.key
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.vehicle.brand} ${widget.vehicle.nama}'),
        actions: [
          Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, child) {
              return IconButton(
                icon: Icon(
                  favoriteProvider.isFavorite(widget.vehicle.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: favoriteProvider.isFavorite(widget.vehicle.id)
                      ? Colors.red
                      : null,
                ),
                onPressed: () => favoriteProvider.toggleFavorite(widget.vehicle.id),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              widget.vehicle.imageUrl.isNotEmpty
                ? widget.vehicle.imageUrl
                : 'img/avanza.jpg',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.vehicle.brand} ${widget.vehicle.nama}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${widget.vehicle.tarif.toStringAsFixed(0)}/hari',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Spesifikasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSpecItem(Icons.car_rental, 'Tipe', widget.vehicle.type),
                  _buildSpecItem(Icons.settings, 'Transmisi', widget.vehicle.transmisi),
                  _buildSpecItem(Icons.people, 'Kapasitas', '${widget.vehicle.kapasitas} Orang'),
                  const SizedBox(height: 16),
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.vehicle.deskripsi),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.vehicle.isAvailable
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FormScreen(vehicle: widget.vehicle)
                            )
                          );
                        }
                        : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)
                        ),
                      ),
                      child: Text(
                        widget.vehicle.isAvailable ? 'Sewa Sekarang' : 'Tidak Tersedia',
                        style: const TextStyle(
                          fontSize: 16
                        ),
                      ),
                    ),
                  )
                ]
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}