import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:venueupi/auth_form/register.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 125,
                height: 130,
                color: Color(0xFFFFCC34),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 80,
                height: 80,
                color: Color(0xFFFFCC34),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: MediaQuery.of(context).size.width < 600
                        ? MediaQuery.of(context).size.width * 0.9
                        : 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: 60,
                              height: 3,
                              color: Color(0xFFE21F27),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                                color: const Color.fromARGB(255, 5, 5, 5)),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Aksi ketika tombol login diklik
                            print('Login button pressed');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(
                                0xFFE21F27), // Menggunakan kode warna E21F27
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(color: Color(0xFFFAE7AD)),
                          ),
                        ),
                        SizedBox(height: 20),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Tidak Punya Akun? ',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                              TextSpan(
                                text: 'Daftar di sini',
                                style: TextStyle(
                                    color: Color(0xFFE21F27), fontSize: 16),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RegisterPage(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFCC34)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)             // Titik awal (pojok kiri atas)
      ..lineTo(size.width, 0)    // Garis ke kanan
      ..lineTo(0, size.height)   // Garis ke bawah kiri
      ..close();                 // Tutup segitiga

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

