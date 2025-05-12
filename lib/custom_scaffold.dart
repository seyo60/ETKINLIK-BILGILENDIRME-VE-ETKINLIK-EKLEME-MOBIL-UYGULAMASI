import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String currentRoute;

  const CustomScaffold({
    super.key,
    required this.body,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: body,
      bottomNavigationBar: NavigationBar(
        indicatorColor: Colors.transparent,
        selectedIndex: _getSelectedIndex(currentRoute),
        onDestinationSelected: (index) {
          _navigateToPage(index, context);
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.celebration), label: 'Etkinlikler'),
          NavigationDestination(
              icon: Icon(Icons.heat_pump_rounded), label: 'Favoriler'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Harita'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month), label: 'Takvim'),
          NavigationDestination(
              icon: Icon(Icons.verified_user), label: 'Profilim'),
        ],
      ),
    );
  }

  int _getSelectedIndex(String currentRoute) {
    switch (currentRoute) {
      case '/home':
        return 0;
      case '/favorites':
        return 1;
      case '/map':
        return 2;
      case '/calendar':
        return 3;
      case '/profile':
        return 4;
      default:
        return 0; // Varsayılan sayfa
    }
  }

  void _navigateToPage(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/favorites');
        break;
      case 2:
        context.go('/map');
        break;
      case 3:
        context.go('/calendar');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  AppBar _appBarWidget() {
    return AppBar(
      title: const Text(
        'Etkinlik Keşfet',
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}
