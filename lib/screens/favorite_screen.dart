import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_ez_rent/data/dummy_data.dart';
import 'package:uas_ez_rent/models/vehicle.dart';
import 'package:uas_ez_rent/providers/favorite_provider.dart';
import 'package:uas_ez_rent/screens/details_screen.dart';
import 'package:uas_ez_rent/screens/history_screen.dart';
import 'package:uas_ez_rent/screens/home_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Placeholder(),
    const HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<FavoriteProvider>(context, listen: false).initializeFavorites()
    );
  }

  Future<void> _loadFavorites() async {
    await context.read<FavoriteProvider>().initializeFavorites();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => _screens[index],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kendaraan Favorit'),
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          if (favoriteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favoriteProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    favoriteProvider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFavorites,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final favoriteVehicles = favoriteProvider.getFavoriteVehicles(dummyVehicles);
          if (favoriteVehicles.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: favoriteVehicles.length,
            itemBuilder: (context, index) {
              final vehicle = favoriteVehicles[index];
              return _buildFavoriteItem(vehicle, favoriteProvider);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(Vehicle vehicle, FavoriteProvider favoriteProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Image.asset(
          vehicle.imageUrl.isNotEmpty ? vehicle.imageUrl : 'assets/images/placeholder.png',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
        title: Text(
          '${vehicle.brand} ${vehicle.nama}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Rp ${vehicle.tarif.toStringAsFixed(0)}/hari',
          style: TextStyle(color: Colors.blue[700]),
        ),
        trailing: IconButton(
          icon: Icon(
            favoriteProvider.isFavorite(vehicle.id)
                ? Icons.favorite
                : Icons.favorite_border,
            color: favoriteProvider.isFavorite(vehicle.id)
                ? Colors.red
                : Colors.grey,
          ),
          onPressed: () => favoriteProvider.toggleFavorite(vehicle.id),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(vehicle: vehicle),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada kendaraan favorit',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan kendaraan ke favorit dari halaman detail',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}