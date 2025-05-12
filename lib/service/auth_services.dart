import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthServices {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Google ile giriş yapma fonksiyonu
  Future<bool> signInWithGoogle() async {
    try {
      // Google ile oturum aç
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Kullanıcı giriş yapmadıysa false döndür
        return false;
      }

      // Google giriş işlemi başarılı ise, GoogleSignInAuthentication almak için devam et
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Burada, Google kimlik doğrulama bilgilerini alıp, backend'e gönderebilirsiniz
      // Eğer başarılıysa, true döndür
      return true;
    } catch (e) {
      // Hata durumunda false döndür
      print("Giriş Hatası: $e");
      return false;
    }
  }
}
