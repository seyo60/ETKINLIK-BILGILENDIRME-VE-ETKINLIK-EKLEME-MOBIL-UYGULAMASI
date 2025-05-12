import 'package:donem_projesi/pages/forgotten_password.dart';
import 'package:go_router/go_router.dart';
import 'package:donem_projesi/service/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:donem_projesi/service/auth_repository.dart';
import 'package:donem_projesi/pages/sign_up.dart';
import 'package:donem_projesi/pages/home.dart';
import 'package:donem_projesi/pages/favorites.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? errorMessage;

  final AuthRepository authRepository =
      AuthRepository(auth: FirebaseAuth.instance);

  // Giriş işlemi
  Future<void> signIn() async {
    try {
      await authRepository.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
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
          'Giriş ve Kayıt Sayfası',
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
              controller: emailController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(25),
                border: OutlineInputBorder(),
                hintText: "E-Postanızı giriniz",
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
              onPressed: () async {
                try {
                  await authRepository.signInWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );
                  setState(() {
                    errorMessage = null;
                  });

                  context.go('/home'); // Doğrudan '/home' rotasına git
                } on FirebaseAuthException catch (e) {
                  setState(() {
                    errorMessage =
                        "E-Posta ya da şifre hatalı veya ikisi de birden hatalı.";
                  });
                } catch (e) {
                  setState(() {
                    errorMessage = "Beklenmedik bir hata oluştu: $e";
                  });
                }
              },
              child: const Text("Giriş Yap"),
            ),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ForgottenPasswordPage()),
                );
              },
              child: const Text("Şifremi Unuttum"),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpPage()),
              ),
              child: const Text("Kayıt Ol"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () async {
                    bool isLoggedIn = await AuthServices().signInWithGoogle();
                    if (isLoggedIn) {
                      // Giriş başarılıysa, HomePage'e yönlendirme
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HomePage(), // HomePage'e yönlendirme
                        ),
                      );
                    } else {
                      // Giriş başarısızsa, hata mesajı göster
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Giriş başarısız!")),
                      );
                    }
                  },
                  icon: const Icon(Icons.email),
                )
              ],
            ),
            errorMessage != null
                ? Text(errorMessage!, style: TextStyle(color: Colors.red))
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
