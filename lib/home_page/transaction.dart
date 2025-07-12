import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:venueupi/history_page/history.dart';

class TransactionPage extends StatefulWidget {
  final String title;
  final String imagePath;
  final int pricePerDay;

  const TransactionPage({
    super.key,
    required this.title,
    required this.imagePath,
    required this.pricePerDay,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  DateTime? selectedDate;

  bool? isDP;
  String? metodePembayaran;

  int get subtotal => selectedDate == null ? 0 : widget.pricePerDay;

  int get total {
    if (selectedDate == null || isDP == null) return 0;
    return isDP! ? widget.pricePerDay ~/ 2 : widget.pricePerDay;
  }

  int get sisaPembayaran {
    if (isDP == true) {
      return widget.pricePerDay ~/ 2;
    }
    return 0;
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFCC34),
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: const Text('Transaction', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFFFCC34),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        widget.imagePath,
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Harga Sewa/hari : ${currencyFormat.format(widget.pricePerDay)}",
                      style: const TextStyle(
                        color: Color(0xFFE5F5EA),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Pilih Tanggal
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFFFFE599),
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate == null
                          ? 'Pilih Tanggal Sewa'
                          : DateFormat('dd MMM yyyy').format(selectedDate!),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.black),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(currencyFormat.format(subtotal)),
              ],
            ),
            const SizedBox(height: 16),
            // Metode Pembayaran
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Checkbox(
                      value: isDP == true,
                      activeColor: Color(0xFFE21F27),
                      onChanged: (_) {
                        setState(() {
                          isDP = true;
                        });
                      },
                    ),
                    const Text("DP"),
                    const SizedBox(width: 8),
                    Checkbox(
                      value: isDP == false,
                      activeColor: Color(0xFFE21F27),
                      onChanged: (_) {
                        setState(() {
                          isDP = false;
                        });
                      },
                    ),
                    const Text("Full"),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: metodePembayaran,
              hint: const Text("Pilih Metode Pembayaran"),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFFFE599),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              focusColor: Colors.transparent,
              iconEnabledColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              items: ['Transfer Bank', 'OVO', 'Gopay', 'Cash']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  metodePembayaran = val;
                });
              },
            ),

            const Spacer(),
            // Total
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  currencyFormat.format(total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            if (isDP == true)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sisa Pembayaran',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      currencyFormat.format(sisaPembayaran),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Validasi
                if (selectedDate == null ||
                    isDP == null ||
                    metodePembayaran == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text("Mohon lengkapi semua data terlebih dahulu")),
                  );
                  return;
                }

                // Ambil user yang sedang login
                final user = FirebaseAuth.instance.currentUser;

                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User belum login")),
                  );
                  return;
                }

                try {
                  // Simpan ke Firestore
                  await FirebaseFirestore.instance.collection('pesanan').add({
                    'uid': user.uid,
                    'title': widget.title,
                    'tanggal': Timestamp.fromDate(selectedDate!),
                    'harga': subtotal,
                    'status': 'PESANAN',
                    'metodePembayaran': metodePembayaran,
                    'isDP': isDP,
                    'sisaPembayaran': isDP! ? sisaPembayaran : 0,
                    'imagePath': widget.imagePath,
                    'timestamp': Timestamp.now(),
                  });

                  // Navigasi ke halaman History (tab Pesanan)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistoryPage(initialTab: 0),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal menyimpan: $e")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE21F27),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Sewa',
                  style: TextStyle(color: Color(0xFFFAE7AD))),
            )
          ],
        ),
      ),
    );
  }
}
