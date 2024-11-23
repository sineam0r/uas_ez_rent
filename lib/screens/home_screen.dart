import 'package:flutter/material.dart';
import 'package:uas_ez_rent/data/dummy_data.dart';
import 'package:uas_ez_rent/models/vehicle.dart';
import 'package:uas_ez_rent/screens/details_screen.dart';
import 'package:uas_ez_rent/screens/favorite_screen.dart';
import 'package:uas_ez_rent/screens/history_screen.dart';
import 'package:uas_ez_rent/screens/profile_screen.dart';
import 'package:uas_ez_rent/widgets/vehicle_card.dart';
import 'package:uas_ez_rent/widgets/category_item.dart';
import 'package:uas_ez_rent/widgets/promo_card.dart';
import 'package:uas_ez_rent/widgets/empty_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  List<Vehicle> _filteredVehicles = [];

  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const Placeholder(),
    const FavoritesScreen(),
    const HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => _screens[index],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _filteredVehicles = dummyVehicles;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterVehicles();
  }

  void _filterVehicles() {
    setState(() {
      _filteredVehicles = dummyVehicles.where((vehicle) {
        if (_selectedCategory != 'Semua' && vehicle.type != _selectedCategory) {
          return false;
        }
        if (_searchController.text.isEmpty) {
          return true;
        }
        final searchTerm = _searchController.text.toLowerCase();
        return vehicle.nama.toLowerCase().contains(searchTerm) ||
            vehicle.brand.toLowerCase().contains(searchTerm) ||
            vehicle.type.toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EZRent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String result) {
              setState(() {
                switch (result) {
                  case 'Termurah':
                    _filteredVehicles.sort((a, b) => a.tarif.compareTo(b.tarif));
                    break;
                  case 'Termahal':
                    _filteredVehicles.sort((a, b) => b.tarif.compareTo(a.tarif));
                    break;
                }
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Termurah',
                child: Text('Harga Termurah'),
              ),
              const PopupMenuItem<String>(
                value: 'Termahal',
                child: Text('Harga Termahal'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mau sewa kendaraan apa?',
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari kendaraan...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      filled: true,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kategori',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12.0),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CategoryItem(
                          icon: Icons.category,
                          label: 'Semua',
                          isSelected: _selectedCategory == 'Semua',
                          onTap: () => _onCategorySelected('Semua'),
                        ),
                        const SizedBox(width: 12),
                        CategoryItem(
                          icon: Icons.car_rental,
                          label: 'Mobil',
                          isSelected: _selectedCategory == 'Mobil',
                          onTap: () => _onCategorySelected('Mobil'),
                        ),
                        const SizedBox(width: 12),
                        CategoryItem(
                          icon: Icons.two_wheeler,
                          label: 'Motor',
                          isSelected: _selectedCategory == 'Motor',
                          onTap: () => _onCategorySelected('Motor'),
                        ),
                        const SizedBox(width: 12),
                        CategoryItem(
                          icon: Icons.electric_bike,
                          label: 'Sepeda',
                          isSelected: _selectedCategory == 'Sepeda',
                          onTap: () => _onCategorySelected('Sepeda'),
                        ),
                        const SizedBox(width: 12),
                        CategoryItem(
                          icon: Icons.local_shipping,
                          label: 'Pick Up',
                          isSelected: _selectedCategory == 'Pick Up',
                          onTap: () => _onCategorySelected('Pick Up'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory == 'Semua'
                            ? 'Kendaraan Tersedia'
                            : 'Kendaraan $_selectedCategory',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (_filteredVehicles.length != dummyVehicles.length)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = 'Semua';
                              _searchController.clear();
                            });
                            _filterVehicles();
                          },
                          child: const Text('Reset Filter'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  _filteredVehicles.isEmpty
                      ? const EmptyState(
                          message: 'Tidak ada kendaraan yang ditemukan',
                        )
                      : SizedBox(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filteredVehicles.length,
                            itemBuilder: (context, index) => VehicleCard(
                              vehicle: _filteredVehicles[index],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(
                                      vehicle: _filteredVehicles[index]),
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            Container(
              height: 200,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: const [
                  PromoCard(
                    title: 'Diskon 10%',
                    description: 'Untuk pemesanan mobil di hari kerja',
                    color: Colors.blue,
                  ),
                  PromoCard(
                    title: 'Gratis 1 Hari',
                    description: 'Untuk pemesanan minimal 7 hari',
                    color: Colors.orange,
                  ),
                  PromoCard(
                    title: 'Cashback 5%',
                    description: 'Untuk pembayaran via transfer bank',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
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
}
