import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uas_ez_rent/models/vehicle.dart';

class FavoriteProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _favoriteIds = [];
  bool _isLoading = false;
  String? _error;

  List<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initializeFavorites() async {
    final user = _auth.currentUser;
    if (user == null) {
      _error = 'Pengguna belum login';
      return;
    }

    _isLoading = true;
    _error = null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc('vehicles')
          .get();

      if (!doc.exists) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc('vehicles')
            .set({
          'ids': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
        _favoriteIds = [];
      } else {
        final data = doc.data();
        _favoriteIds = data != null ? List<String>.from(data['ids'] ?? []) : [];
      }
      _error = null;
    } catch (e) {
      _error = 'Terjadi kesalahan saat memuat favorit: $e';
      _favoriteIds = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(String vehicleId) async {
    final user = _auth.currentUser;
    if (user == null) {
      _error = 'Pengguna belum login';
      notifyListeners();
      return;
    }

    final userFavoritesRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc('vehicles');

    try {
      final updatedIds = List<String>.from(_favoriteIds);
      if (updatedIds.contains(vehicleId)) {
        updatedIds.remove(vehicleId);
      } else {
        updatedIds.add(vehicleId);
      }

      await userFavoritesRef.set({
        'ids': updatedIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _favoriteIds = updatedIds;
      notifyListeners();
    } catch (e) {
      _error = 'Terjadi kesalahan saat memperbarui favorit: $e';
      notifyListeners();
      await initializeFavorites();
    }
  }

  bool isFavorite(String vehicleId) {
    return _favoriteIds.contains(vehicleId);
  }

  List<Vehicle> getFavoriteVehicles(List<Vehicle> allVehicles) {
    return allVehicles.where((vehicle) => _favoriteIds.contains(vehicle.id)).toList();
  }
}