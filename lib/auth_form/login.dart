import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:venueupi/auth_form/register.dart';
import 'package:venueupi/home_page.dart/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String pesan = '';
  bool _isPasswordVisible = false;
  bool isLoading = false;

  void login() async {
    setState(() {
      isLoading = true;
    });
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        pesan = "Username dan password harus diisi";
        isLoading = false;
      });
      return;
    }

    try {
      // Cari email berdasarkan username di Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          pesan = "Username tidak ditemukan";
          isLoading = false;
        });
        return;
      }

      final userData = snapshot.docs.first.data();
      final email = userData['email'];

      // Login ke Firebase Auth pakai email & password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      setState(() {
        pesan = "Login berhasil";
      });
      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      setState(() {
        pesan = "Login gagal: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
                color: const Color(0xFFFFCC34),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 80,
                height: 80,
                color: const Color(0xFFFFCC34),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: MediaQuery.of(context).size.width < 600
                      ? MediaQuery.of(context).size.width * 0.9
                      : 400,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 60,
                        height: 3,
                        color: const Color(0xFFE21F27),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        pesan,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            )),
                      ),
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE21F27),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(color: Color(0xFFFAE7AD)),
                              ),
                            ),
                      const SizedBox(height: 20),
                      isLoading
                          ? const Text(
                              "sedang login...",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic),
                            )
                          : RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Tidak Punya Akun? ',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                  TextSpan(
                                    text: 'Daftar di sini',
                                    style: const TextStyle(
                                        color: Color(0xFFE21F27), fontSize: 16),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AuthForm(),
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
          ],
        ),
      ),
    );
  }
}
