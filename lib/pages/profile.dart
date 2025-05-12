import 'package:donem_projesi/pages/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "Loading...";
  String email = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Kullanıcı verilerini getirme
  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Authenticationdan e-posta bilgisi alma
      email = user.email ?? "No Email";

      // Firestoredan ad bilgisi alma
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('name')
          .doc(user.uid)
          .get();

      setState(() {
        name = userDoc['name'] ?? "No Name";
      });
    }
  }

  // Bilgi güncelleme pop-up ı
  Future<void> updateUserInfo(BuildContext context) async {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController emailController = TextEditingController(text: email);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Info"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "E-mail"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // Firestoreda kullanıcı adını güncelleme
                  await FirebaseFirestore.instance
                      .collection('name')
                      .doc(user.uid)
                      .set({
                    'name': nameController.text,
                  });

                  // Firebase Authenticationda e-posta güncelleme
                  try {
                    setState(() {
                      email = emailController.text;
                      name = nameController.text;
                    });
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Email update failed: $error")),
                    );
                  }
                }
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Çıkış yapma fonksiyonu
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(
        context, '/login'); // Login sayfasına yönlendirme
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              // Çıkış işlemi
              await signOut();
              // Çıkış yaptıktan sonra SignUpPage e yönlendir
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 65,
              backgroundImage: const NetworkImage(
                'https://mir-s3-cdn-cf.behance.net/project_modules/fs/5e227329363657.55ef8df90a1ca.png',
              ),
            ),
            const SizedBox(height: 20),
            itemProfile('Name', name, CupertinoIcons.person),
            itemProfile('E-posta', email, CupertinoIcons.mail_solid),
          ],
        ),
      ),
    );
  }

  Widget itemProfile(String title, String subtitle, IconData icon) {
    return Container(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(icon),
        trailing: title == 'Name' || title == 'E-posta'
            ? IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => updateUserInfo(context),
              )
            : null,
      ),
    );
  }
}
