import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uas_ez_rent/providers/user_provider.dart';
import 'dart:io';
import 'package:uas_ez_rent/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  dynamic _ktpImage;
  dynamic _simImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUserData();
      final userData = userProvider.userData;

      if (userData != null) {
        setState(() {
          _nameController.text = userData.nama ?? '';
          _phoneController.text = userData.notelp ?? '';
          _addressController.text = userData.alamat ?? '';
          _ktpImage = userData.ktpImageUrl;
          _simImage = userData.simImageUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final String ktpStatus = _ktpImage != null ? 'uploaded' : '';
        final String simStatus = _simImage != null ? 'uploaded' : '';

        await userProvider.updateUserData(
          nama: _nameController.text,
          notelp: _phoneController.text,
          alamat: _addressController.text,
          ktpImageUrl: ktpStatus.isNotEmpty ? ktpStatus : null,
          simImageUrl: simStatus.isNotEmpty ? simStatus : null,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil disimpan')),
        );
        await _loadUserData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving profile: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          if (type == 'ktp') {
            _ktpImage = bytes;
          } else {
            _simImage = bytes;
          }
        });
      } else {
        setState(() {
          if (type == 'ktp') {
            _ktpImage = File(image.path);
          } else {
            _simImage = File(image.path);
          }
        });
      }
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Pribadi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor telepon tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Dokumen',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDocumentUpload(
                      'KTP',
                      _ktpImage,
                      () => _pickImage(ImageSource.gallery, 'ktp'),
                      () => _pickImage(ImageSource.camera, 'ktp'),
                    ),
                    const SizedBox(height: 16),
                    _buildDocumentUpload(
                      'SIM',
                      _simImage,
                      () => _pickImage(ImageSource.gallery, 'sim'),
                      () => _pickImage(ImageSource.camera, 'sim'),
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Simpan Profile',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDocumentUpload(
    String title,
    dynamic image,
    VoidCallback onGalleryTap,
    VoidCallback onCameraTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload $title'),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: image == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.photo_library),
                          onPressed: onGalleryTap,
                          tooltip: 'Pick from gallery',
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: onCameraTap,
                          tooltip: 'Take a picture',
                        ),
                      ],
                    ),
                    const Text('Tap to upload'),
                  ],
                )
              : Stack(
                  children: [
                    if  (kIsWeb && image is Uint8List)
                      Image.memory(
                        image,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    else if (!kIsWeb && image is File)
                      Image.file(
                        image,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            if (title == 'KTP') {
                              _ktpImage = null;
                            } else {
                              _simImage = null;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
