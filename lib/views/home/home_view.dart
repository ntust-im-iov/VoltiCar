import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/observer.dart';
import '../../viewmodels/auth_viewmodel.dart'; // Assuming we might need this later
import 'garage_view.dart'; // 引入車庫視圖

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> implements EventObserver {
  final AuthViewModel _authViewModel = AuthViewModel(); // Keep the view model
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
    _authViewModel.subscribe(this);
    _logger.i('HomeView initialized');
  }

  @override
  void dispose() {
    _authViewModel.unsubscribe(this);
    super.dispose();
    _logger.i('HomeView disposed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 移除 AppBar，以提供更多顯示空間
      body: const GarageView(),
      backgroundColor: const Color(0xFF0F0A1F), // 確保背景顏色一致
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
    // TODO: Implement event handling if needed
    _logger.i('Received event: ${event.runtimeType}');
  }
}
