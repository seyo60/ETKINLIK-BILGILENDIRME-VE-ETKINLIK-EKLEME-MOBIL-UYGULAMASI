import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:donem_projesi/service/auth_repository.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  String? errorMessage;

  final AuthRepository authRepository =
      AuthRepository(auth: FirebaseAuth.instance);
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Kayıt işlemi
  Future<void> createUser() async {
    try {
      // Kullanıcıyı e-posta ve şifre ile oluşturma
      await authRepository.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Firebase Authenticationdan kullanıcı adı ekleme
        await user.updateDisplayName(nameController.text);

        // Firebase Firestoreda name koleksiyonuna veriyi kaydetme
        await FirebaseFirestore.instance.collection('name').doc(user.uid).set({
          'name': nameController
              .text, // name alanını kullanıcıdan alınan değer ile güncelle
        });
      }

      setState(() {
        errorMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kayıt başarılı!")),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "Bir hata oluştu.";
      });
    } catch (e) {
      setState(() {
        errorMessage = "Beklenmedik bir hata oluştu: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kayıt Sayfası',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade200,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.network(
              "https://mir-s3-cdn-cf.behance.net/project_modules/fs/5e227329363657.55ef8df90a1ca.png",
              width: 150,
            ),
            const Text(
              'Hoşgeldiniz!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(25),
                border: OutlineInputBorder(),
                hintText: "Adınızı giriniz",
              ),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(25),
                border: OutlineInputBorder(),
                hintText: "E-posta adresinizi giriniz",
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(25),
                border: OutlineInputBorder(),
                hintText: "Şifrenizi giriniz",
              ),
            ),
            ElevatedButton(
              onPressed: () => createUser(),
              child: const Text("Kayıt Ol"),
            ),
            errorMessage != null
                ? Text(errorMessage!, style: TextStyle(color: Colors.red))
                : const SizedBox.shrink(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Giriş Yap"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [],
            ),
          ],
        ),
      ),
    );
  }
}
