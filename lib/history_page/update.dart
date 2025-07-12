import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:venueupi/history_page/history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdatePage extends StatefulWidget {
  final Pesanan pesanan;

  const UpdatePage({super.key, required this.pesanan});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.pesanan.tanggal;
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = selectedDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
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
        title: const Text("Transaction", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.pesanan.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      widget.pesanan.imagePath,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFCC34),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Harga Sewa/hari : ${currencyFormat.format(widget.pesanan.harga)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),

              /// Tanggal sewa
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tanggal Sewa'),
                  TextButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(DateFormat('dd MMMM yyyy', 'id_ID')
                        .format(selectedDate)),
                  ),
                ],
              ),
              const Divider(thickness: 1),

              /// Subtotal
              buildRowWithDivider(
                  'Subtotal', currencyFormat.format(widget.pesanan.harga)),

              /// Bayar
              buildRowWithDivider(
                  'Bayar', currencyFormat.format(widget.pesanan.harga ~/ 2)),

              /// Sisa
              buildRowWithDivider(
                  'Sisa', currencyFormat.format(widget.pesanan.harga ~/ 2)),

              /// Pembayaran
              buildRowWithDivider('Pembayaran', 'DP'),

              const SizedBox(height: 32),

              /// Tombol Update
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;

                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User belum login")),
                      );
                      return;
                    }

                    final snapshot = await FirebaseFirestore.instance
                        .collection('pesanan')
                        .where('uid', isEqualTo: user.uid)
                        .get();

                    QueryDocumentSnapshot<Map<String, dynamic>>? matchingDoc;

                    try {
                      matchingDoc = snapshot.docs.firstWhere(
                        (doc) {
                          final data = doc.data();
                          final DateTime tanggal =
                              (data['tanggal'] as Timestamp).toDate();
                          final sameDate = tanggal.year ==
                                  widget.pesanan.tanggal.year &&
                              tanggal.month == widget.pesanan.tanggal.month &&
                              tanggal.day == widget.pesanan.tanggal.day;

                          return data['title'] == widget.pesanan.title &&
                              sameDate;
                        },
                      );
                    } catch (e) {
                      matchingDoc = null;
                    }

                    if (matchingDoc != null) {
                      final docId = matchingDoc.id;
                      await FirebaseFirestore.instance
                          .collection('pesanan')
                          .doc(docId)
                          .update({
                        'tanggal': selectedDate,
                      });

                      final updatedPesanan = Pesanan(
                        title: widget.pesanan.title,
                        tanggal: selectedDate,
                        harga: widget.pesanan.harga,
                        status: widget.pesanan.status,
                        imagePath: widget.pesanan.imagePath,
                      );

                      Navigator.pop(context, updatedPesanan);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Data tidak ditemukan di database")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE21F27),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Update',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildRowWithDivider(String label, String value) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
      const SizedBox(height: 6),
      const Divider(thickness: 1, color: Colors.grey),
      const SizedBox(height: 6),
    ],
  );
}
