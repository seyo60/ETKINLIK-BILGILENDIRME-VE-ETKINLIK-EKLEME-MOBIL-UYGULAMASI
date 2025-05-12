import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:donem_projesi/pages/login.dart'; 
import 'package:donem_projesi/pages/home.dart'; 
import 'package:donem_projesi/pages/map.dart'; 
import 'package:donem_projesi/pages/calendar.dart'; 
import 'package:donem_projesi/pages/profile.dart';
import 'package:donem_projesi/custom_scaffold.dart'; 
import 'package:donem_projesi/themes/theme.dart';
import 'package:donem_projesi/pages/favorites.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDOfTRVvGq2wA12z9_EeLZ9ptkLBEFZEEY",
        authDomain: "donemprojesifirebase.firebaseapp.com",
        projectId: "donemprojesifirebase",
        storageBucket: "donemprojesifirebase.firebasestorage.app",
        messagingSenderId: "1081301390573",
        appId: "1:1081301390573:web:3b492834eab09d3c0368e4",
        measurementId: "G-WHD11M7ZYC",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // GoRouter yapılandırmasını 
  final GoRouter _router = GoRouter(
    initialLocation: '/', // Uygulamanın başlangıç rotası
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Login(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => CustomScaffold(
          body: const HomePage(),
          currentRoute: '/home',
        ),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => CustomScaffold(
          body: const FavoritesPage(),
          currentRoute: '/favorites',
        ),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => CustomScaffold(
          body: const MapPage(),
          currentRoute: '/map',
        ),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => CustomScaffold(
          body: const CalendarPage(),
          currentRoute: '/calendar',
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => CustomScaffold(
          body: const ProfilePage(),
          currentRoute: '/profile',
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router, // GoRouter yapılandırması
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
