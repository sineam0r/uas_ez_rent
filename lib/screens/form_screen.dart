import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uas_ez_rent/models/vehicle.dart';
import 'package:uas_ez_rent/providers/user_provider.dart';
import 'package:uas_ez_rent/screens/history_screen.dart';
import 'package:uas_ez_rent/screens/profile_screen.dart';

class FormScreen extends StatefulWidget {
  final Vehicle vehicle;

  const FormScreen({
    required this.vehicle, super.key
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  String _paymentCategory = 'Tunai';
  String _selectedPaymentMethod = 'Tunai';
  final Map<String, List<String>> _paymentMethods = {
    'Tunai': ['Tunai'],
    'Transfer Bank': ['BCA', 'Mandiri', 'BNI', 'BRI', 'Bank Lainnya'],
    'E-Wallet': ['GoPay', 'OVO', 'DANA', 'ShopeePay', 'LinkAja'],
  };
  int _rentalDays = 0;
  double _totalHarga = 0;

  @override
  void dispose() {
    _namaController.dispose();
    _telpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (_startDate != null && _endDate != null) {
      _rentalDays = _endDate!.difference(_startDate!).inDays + 1;
      _totalHarga = _rentalDays * widget.vehicle.tarif;
    } else {
      _rentalDays = 0;
      _totalHarga = 0;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProfileCompletion();
    });
  }

  Future<void> _checkProfileCompletion() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUserData();

    if (!userProvider.isProfileComplete) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Profile tidak lengkap'),
            content: const Text(
              'Lengkapi profile Anda terlebih dahulu sebelum melakukan penyewaan.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Lengkapi Profile'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    )
                  ).then((_) => _checkProfileCompletion());
                },
              )
            ],
          );
        }
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? DateTime.now() : (_startDate ?? DateTime.now()),
      firstDate: isStartDate ? DateTime.now() : (_startDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
      _calculateTotal();
    }
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metode Pembayaran',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _paymentCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _paymentCategory = newValue!;
                  _selectedPaymentMethod = _paymentMethods[newValue]!.first;
                });
              },
              items: _paymentMethods.keys.map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedPaymentMethod,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue!;
                });
              },
              items: _paymentMethods[_paymentCategory]!.map<DropdownMenuItem<String>>((String method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
Widget build(BuildContext context) {
  return Consumer<UserProvider>(
    builder: (context, userProvider, _) {
      if (!userProvider.isProfileComplete) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Form Sewa Kendaraan'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Profile Belum Lengkap',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Anda harus melengkapi profile sebelum memesan kendaraan',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    ).then((_) => _checkProfileCompletion());
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Lengkapi Profile'),
                ),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Form Sewa Kendaraan'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Image.asset(
                          widget.vehicle.imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.vehicle.brand} ${widget.vehicle.nama}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rp ${widget.vehicle.tarif.toStringAsFixed(0)}/hari',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Periode Sewa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tanggal Mulai',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                _startDate == null
                                    ? 'Pilih Tanggal'
                                    : DateFormat('dd MMM yyy').format(_startDate!),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: GestureDetector(
                        onTap: _startDate == null
                            ? null
                            : () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _startDate == null
                                  ? Colors.grey.shade300
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tanggal Selesai',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                _endDate == null
                                    ? 'Pilih Tanggal'
                                    : DateFormat('dd MMM yyy').format(_endDate!),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _startDate == null
                                      ? Colors.grey.shade400
                                      : Colors.black,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Informasi Pemesan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: userProvider.userData?.nama,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pemesan',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: userProvider.userData?.notelp,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: userProvider.userData?.alamat,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Pemesan',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                if (_rentalDays > 0)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rincian Biaya',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Durasi Sewa'),
                              Text('$_rentalDays Hari')
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Biaya',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Rp ${_totalHarga.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildPaymentMethodSection(),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _startDate != null &&
                          _endDate != null) {
                        final rentalData = {
                          'vehicle': widget.vehicle,
                          'startDate': _startDate!,
                          'endDate': _endDate!,
                          'totalCost': _totalHarga,
                          'status': 'Berlangsung',
                          'userName': userProvider.userData?.nama,
                          'userPhone': userProvider.userData?.notelp,
                          'userAddress': userProvider.userData?.alamat,
                        };

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Pemesanan berhasil! total: Rp ${_totalHarga.toStringAsFixed(0)}. Pembayaran via $_selectedPaymentMethod',
                            ),
                          ),
                        );

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryScreen(
                              newRental: rentalData,
                            ),
                          ),
                          (route) => false,
                        );
                      } else if (_startDate == null || _endDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pilih periode sewa'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      _totalHarga > 0
                          ? 'Pesan Sekarang (Rp ${_totalHarga.toStringAsFixed(0)})'
                          : 'Pesan Sekarang',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
}


