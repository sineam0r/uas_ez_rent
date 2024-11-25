import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserData {
  String? nama;
  String? notelp;
  String? alamat;
  String? ktpImageUrl;
  String? simImageUrl;

  UserData({
    this.nama,
    this.notelp,
    this.alamat,
    this.ktpImageUrl,
    this.simImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'notelp': notelp,
      'alamat': alamat,
      'ktpImageUrl': ktpImageUrl,
      'simImageUrl': simImageUrl,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      nama: map['nama'],
      notelp: map['notelp'],
      alamat: map['alamat'],
      ktpImageUrl: map['ktpImageUrl'],
      simImageUrl: map['simImageUrl'],
    );
  }
}

class UserProvider with ChangeNotifier {
  UserData? _userData;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserData? get userData => _userData;

  bool get isProfileComplete {
    return _userData != null &&
        _userData!.nama != null &&
        _userData!.nama!.isNotEmpty &&
        _userData!.notelp != null &&
        _userData!.notelp!.isNotEmpty &&
        _userData!.alamat != null &&
        _userData!.alamat!.isNotEmpty;
  }

  Future<void> loadUserData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _userData = UserData.fromMap(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Terjadi kesalahan saat memuat data pengguna: $e');
      rethrow;
    }
  }

  Future<void> updateUserData({
    String? nama,
    String? notelp,
    String? alamat,
    String? ktpImageUrl,
    String? simImageUrl,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Tidak ditemukan pengguna yang telah login');

      final Map<String, dynamic> updatedData = {
        if (nama != null) 'nama': nama,
        if (notelp != null) 'notelp': notelp,
        if (alamat != null) 'alamat': alamat,
        if (ktpImageUrl != null) 'ktpImageUrl': ktpImageUrl,
        if (simImageUrl != null) 'simImageUrl': simImageUrl,
      };

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .set(updatedData, SetOptions(merge: true));

      _userData = UserData(
        nama: nama ?? _userData?.nama,
        notelp: notelp ?? _userData?.notelp,
        alamat: alamat ?? _userData?.alamat,
        ktpImageUrl: ktpImageUrl ?? _userData?.ktpImageUrl,
        simImageUrl: simImageUrl ?? _userData?.simImageUrl,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user data: $e');
      throw Exception('Failed to update user data: $e');
    }
  }
}