import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:venueupi/bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:venueupi/page/history_page/update.dart';

class Pesanan {
  final String title;
  final DateTime tanggal;
  final int harga;
  final String status;
  final String imagePath;

  Pesanan({
    required this.title,
    required this.tanggal,
    required this.harga,
    required this.status,
    required this.imagePath,
  });
}

class HistoryPage extends StatefulWidget {
  final int initialTab;
  const HistoryPage({super.key, required this.initialTab});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Pesanan> pesananList = [];
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    selectedTab = widget.initialTab;
    fetchPesanan();
  }

  Future<void> fetchPesanan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('pesanan')
        .where('uid', isEqualTo: user.uid)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      DateTime? tanggalDate;

      try {
        final rawTanggal = data['tanggal'];
        if (rawTanggal is Timestamp) {
          tanggalDate = rawTanggal.toDate();
        } else if (rawTanggal is String) {
          tanggalDate =
              DateFormat("dd MMM yyyy", 'id_ID').parseStrict(rawTanggal);
        }
      } catch (e) {
        print("Gagal parsing tanggal: $e");
        continue;
      }

      final docId = doc.id;
      if (tanggalDate != null &&
          tanggalDate.isBefore(DateTime.now()) &&
          data['status'] == 'PESANAN') {
        await FirebaseFirestore.instance
            .collection('pesanan')
            .doc(docId)
            .update({'status': 'SELESAI'});
      }
    }

    final refreshedSnapshot = await FirebaseFirestore.instance
        .collection('pesanan')
        .where('uid', isEqualTo: user.uid)
        .get();

    final refreshedList = refreshedSnapshot.docs.map((doc) {
      final data = doc.data();
      return Pesanan(
        title: data['title'] ?? '',
        tanggal: (data['tanggal'] as Timestamp).toDate(),
        harga: data['harga'] ?? 0,
        status: data['status'] ?? 'BATAL',
        imagePath: data['imagePath'] ?? '',
      );
    }).toList();

    final batalSnapshot = await FirebaseFirestore.instance
        .collection('pesanan_dibatalkan')
        .where('uid', isEqualTo: user.uid)
        .get();

    final batalList = batalSnapshot.docs.map((doc) {
      final data = doc.data();
      return Pesanan(
        title: data['title'] ?? '',
        tanggal: (data['tanggal'] as Timestamp).toDate(),
        harga: data['harga'] ?? 0,
        status: 'BATAL',
        imagePath: data['imagePath'] ?? '',
      );
    }).toList();

    setState(() {
      pesananList = [...refreshedList, ...batalList];
    });
  }

  Widget buildTab(String label, int index) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => selectedTab = index),
          child: Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selectedTab == index
                  ? const Color(0xFFFFCC34)
                  : const Color(0xFFF9F5EB),
              borderRadius: BorderRadius.circular(20),
              boxShadow: selectedTab == index
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      )
                    ]
                  : [],
              border: Border.all(color: Colors.black12),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: selectedTab == index ? Colors.black : Colors.black54,
              ),
            ),
          ),
        ));
  }

  Widget buildListByStatus(String status) {
    final currencyFormat = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    final filtered = pesananList.where((p) => p.status == status).toList();

    return ListView.builder(
      itemCount: filtered.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final pesanan = filtered[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            onTap: status == 'PESANAN'
                ? () async {
                    final updatedPesanan = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdatePage(pesanan: pesanan),
                      ),
                    );

                    if (updatedPesanan != null && mounted) {
                      fetchPesanan();
                    }
                  }
                : null,
            title: Text(pesanan.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    DateFormat('dd MMM yyyy', 'id_ID').format(pesanan.tanggal)),
                Text(currencyFormat.format(pesanan.harga),
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            trailing: status == 'PESANAN'
                ? TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFE21F27),
                      foregroundColor: Color(0xFFFAE7AD),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () => showCancelDialog(pesanan),
                    child: const Text('BATAL'),
                  )
                : null,
          ),
        );
      },
    );
  }

  void showCancelDialog(Pesanan pesanan) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Batalkan Pesanan',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Jika pesanan dibatalkan, maka DP kamu akan hangus~',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF1C4),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tidak'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFE21F27),
                        foregroundColor: Color(0xFFFFF1C4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        final user = FirebaseAuth.instance.currentUser;
                        final snapshot = await FirebaseFirestore.instance
                            .collection('pesanan')
                            .where('uid', isEqualTo: user?.uid)
                            .where('title', isEqualTo: pesanan.title)
                            .where('tanggal',
                                isEqualTo: Timestamp.fromDate(pesanan.tanggal))
                            .limit(1)
                            .get();
                        if (snapshot.docs.isNotEmpty) {
                          final doc = snapshot.docs.first;

                          await FirebaseFirestore.instance
                              .collection('pesanan_dibatalkan')
                              .doc(doc.id)
                              .set(doc.data());

                          await FirebaseFirestore.instance
                              .collection('pesanan')
                              .doc(snapshot.docs.first.id)
                              .delete();
                          fetchPesanan();
                        }
                      },
                      child: const Text('Ya'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('History', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildTab('Pesanan', 0),
                buildTab('Riwayat', 1),
                buildTab('Batal', 2),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: IndexedStack(
              index: selectedTab,
              children: [
                buildListByStatus('PESANAN'),
                buildListByStatus('SELESAI'),
                buildListByStatus('BATAL'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0,
        parentContext: context,
      ),
    );
  }
}
