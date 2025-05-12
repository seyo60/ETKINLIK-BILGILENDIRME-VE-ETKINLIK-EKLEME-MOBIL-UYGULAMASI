import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgottenPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  ForgottenPasswordPage({Key? key}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Şifremi Unuttum',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade200,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              "https://mir-s3-cdn-cf.behance.net/project_modules/fs/5e227329363657.55ef8df90a1ca.png",
              width: 150,
            ),
            const Text(
              'Şifrenizi Sıfırlayın!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(25),
                  border: OutlineInputBorder(),
                  hintText: "E-Postanızı giriniz",
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();

                if (email.isNotEmpty) {
                  try {
                    await _auth.sendPasswordResetEmail(email: email);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Şifre sıfırlama bağlantısı gönderildi.')),
                    );
                  } on FirebaseAuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.message ?? 'Bir hata oluştu.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('E-posta alanı boş olamaz.')),
                  );
                }
              },
              child: const Text("Sıfırlama Bağlantısı Al"),
            ),
          ],
        ),
      ),
    );
  }
}
