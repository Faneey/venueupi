import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:venueupi/auth_form/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});
  @override
  State<AuthForm> createState() => RegisterPage();
}

class RegisterPage extends State<AuthForm> {
  final TextEditingController usernamecontroller = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController nomorcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController confirmcontroller = TextEditingController();

  bool isLoading = false;
  bool _isPasswordVisible = false;

  String pesan = "";

  void register() async {
    setState(() {
      isLoading = true;
    });

    if (passwordcontroller.text.isEmpty || confirmcontroller.text.isEmpty) {
      setState(() {
        pesan = 'Password tidak boleh kosong';
        isLoading = false;
      });
      return;
    }

    if (passwordcontroller.text != confirmcontroller.text) {
      setState(() {
        pesan = 'Password Tidak Cocok';
        isLoading = false;
      });
      return;
    }

    if (emailcontroller.text.isEmpty ||
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailcontroller.text)) {
      setState(() {
        pesan = 'Email tidak valid';
      });
      return;
    }

    try {
      print("Mencoba membuat user...");
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailcontroller.text, password: passwordcontroller.text);

      final user = userCredential.user;

      if (user != null) {
        print("User berhasil dibuat: ${user.uid}");
        await user.updateDisplayName(usernamecontroller.text);
        print("Display name diperbarui");

        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': usernamecontroller.text,
          'email': emailcontroller.text,
          'nomor_telepon': nomorcontroller.text
        }).catchError((e) {
          print("Gagal menyimpan ke Firestore: $e");
        });

        print("Data user disimpan ke Firestore");

        setState(() {
          pesan = 'Registrasi Berhasil';
        });

        if (mounted) {
          setState(() {
            isLoading = false;
          });
          print("Navigasi ke LoginPage");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      }
    } catch (e) {
      print("Terjadi error: $e");
      setState(() {
        pesan = 'Registrasi Gagal: ${e.toString()}';
        isLoading = false;
      });
    }
  }

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
                              'Registrasi',
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
                        TextFormField(
                          controller: usernamecontroller,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                          validator: (value) => value!.isEmpty
                              ? 'Username Tidak Boleh Kosong'
                              : null,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: emailcontroller,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            // Validasi format email
                            String pattern = r'^[^@]+@[^@]+\.[^@]+';
                            if (!RegExp(pattern).hasMatch(value)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: nomorcontroller,
                          decoration: InputDecoration(
                            labelText: 'Nomor Telepon',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: passwordcontroller,
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          obscureText: !_isPasswordVisible,
                          controller: confirmcontroller,
                          decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              border: const OutlineInputBorder(),
                              suffix: IconButton(
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konfirmasi password tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () {
                                  register();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(
                                      0xFFE21F27), // Menggunakan kode warna E21F27
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 15),
                                ),
                                child: const Text(
                                  'Sign UP',
                                  style: TextStyle(color: Color(0xFFFAE7AD)),
                                ),
                              ),
                        const SizedBox(height: 20),
                        isLoading
                            ? const Text(
                                "sedang membuat akun...",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic),
                              )
                            : RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Sudah Punya Akun? ',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                    TextSpan(
                                      text: 'Masuk di sini',
                                      style: TextStyle(
                                          color: Color(0xFFE21F27),
                                          fontSize: 16),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => LoginPage(),
                                            ),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                        Center(
                          child: Column(
                            children: [
                              Padding(padding: EdgeInsets.all(20)),
                              Text(
                                pesan,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
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
