import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:venueupi/home_page/home.dart';
import 'package:venueupi/history_page/history.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final BuildContext parentContext;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      selectedItemColor: Colors.amber[700],
      unselectedItemColor: Colors.grey,
      onTap: (index) async {
        if (index == currentIndex) return; // Hindari reload tab yang sama

        if (index == 0) {
          // Navigasi ke halaman History
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HistoryPage(initialTab: 0),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(-1.0, 0.0); // Geser dari kiri
                const end = Offset.zero;
                const curve = Curves.ease;

                final tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        } else if (index == 1) {
          // Navigasi ke halaman Home
          Navigator.pushReplacement(
            parentContext,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else if (index == 2) {
          // Halaman Me belum tersedia
          ScaffoldMessenger.of(parentContext).showSnackBar(
            const SnackBar(content: Text("Halaman Me belum tersedia")),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Me',
        ),
      ],
    );
  }
}
