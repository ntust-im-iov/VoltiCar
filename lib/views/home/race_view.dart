import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/observer.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RaceView extends StatefulWidget {
  const RaceView({super.key});

  @override
  State<RaceView> createState() => _RaceViewState();
}

class _RaceViewState extends State<RaceView> implements EventObserver {
  final AuthViewModel _authViewModel = AuthViewModel();
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
    _authViewModel.subscribe(this);
    _logger.i('RaceView initialized');
  }

  @override
  void dispose() {
    _authViewModel.unsubscribe(this);
    super.dispose();
    _logger.i('RaceView disposed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RACE',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFf2f2f2), // Light grey background
        child: SingleChildScrollView(child: Container()),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.map), label: 'MAP'),
          const BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'RACE'),
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'MY CAR',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'ACCOUNT',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          _logger.i('Bottom navigation tapped: $index');
          switch (index) {
            case 0: // MAP
              Navigator.pushReplacementNamed(context, '/map');
              break;
            case 1: // RACE
              // Stay on the same screen
              break;
            case 2: // HOME
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 3: // MY CAR
              Navigator.pushReplacementNamed(context, '/mycar');
              break;
            case 4: // ACCOUNT
              Navigator.pushReplacementNamed(context, '/account');
              break;
          }
        },
      ),
    );
  }

  Future<void> _handleLogout() async {
    _logger.i('Logout button pressed');
    await _authViewModel.logout();
    if (mounted) {
      _logger.i('Navigating to login screen');
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void notify(ViewEvent event) {
    _logger.i('Received event: ${event.runtimeType}');
  }
}
