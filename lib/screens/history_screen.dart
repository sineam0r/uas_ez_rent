import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uas_ez_rent/screens/favorite_screen.dart';
import 'package:uas_ez_rent/screens/home_screen.dart';

class HistoryScreen extends StatefulWidget {
  final Map<String, dynamic>? newRental;

  const HistoryScreen({super.key, this.newRental});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedIndex = 2;

final List<Widget> _screens = [
  const HomeScreen(),
  const FavoritesScreen(),
  const Placeholder(),
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

  final List<Map<String, dynamic>> _rentalHistory = [];

  @override
  void initState() {
    super.initState();
    if (widget.newRental != null) {
      _rentalHistory.add(widget.newRental!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Sewa'),
      ),
      body: _rentalHistory.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _rentalHistory.length,
            itemBuilder: (context, index) {
              final rental = _rentalHistory[index];
              return _buildHistoryItem(rental);
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

  Widget _buildHistoryItem(Map<String, dynamic> rental) {
    final vehicle = rental['vehicle'];
    final startDate = rental['startDate'];
    final endDate = rental['endDate'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Image.asset(
          vehicle.imageUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
        title: Text(
          '${vehicle.brand} ${vehicle.nama}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Rp ${rental['totalCost'].toStringAsFixed(0)}',
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: rental['status'] == 'Selesai' ? Colors.green : Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            rental['status'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat sewa',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sewa kendaraan untuk melihat riwayat',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}