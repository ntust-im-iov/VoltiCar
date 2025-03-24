import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/observer.dart';
import '../../viewmodels/auth_viewmodel.dart'; // Assuming we might need this later

class MyCarView extends StatefulWidget {
  const MyCarView({super.key});

  @override
  State<MyCarView> createState() => _MyCarViewState();
}

class _MyCarViewState extends State<MyCarView> implements EventObserver {
  final AuthViewModel _authViewModel = AuthViewModel(); // Keep the view model
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
    _authViewModel.subscribe(this);
    _logger.i('MyCarView initialized');
  }

  @override
  void dispose() {
    _authViewModel.unsubscribe(this);
    super.dispose();
    _logger.i('MyCarView disposed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MY CAR',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black, // Match the image
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top section with car model and image
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.black, // Black background for the top section
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // CCS2 Icon (Placeholder)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.ev_station,
                            color: Colors.black,
                          ),
                        ),
                        // Car Model
                        const Text(
                          'TESLA MODEL 3',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Car Image (Placeholder)
                    // Car Image (Placeholder - Grey Container)
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[400], // Darker grey
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Car Image Placeholder',
                          style: TextStyle(color: Colors.white), // White text
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Charging Activity
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Charging Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Charging details (Placeholder)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.attach_money,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('累積金額 9元 / kWh'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '\$3',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('電量 53% -> 53%'),
                            ],
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.green, // Green for charging
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.battery_charging_full,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Curved background
                    Container(
                      height: 40, // Adjust height as needed
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Statistics
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            '距離滿電還有：',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const Text(
                          '00 : 15 : 00',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.5, // Adjust for item height
                      children: [
                        _buildStatItem(Icons.bolt, '上次充電里程', '15,000 KM'),
                        _buildStatItem(Icons.directions_car, '行駛里程', '468 KM'),
                        _buildStatItem(Icons.eco, '平均減碳量', '54.41 kgCO2e'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80), // Add space for the bottom nav bar
            ],
          ),
        ),
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
        currentIndex: 3,
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
              Navigator.pushReplacementNamed(context, '/race');
              break;
            case 2: // HOME
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 3: // MY CAR
              // Stay on the same screen
              break;
            case 4: // ACCOUNT
              Navigator.pushReplacementNamed(context, '/account');
              break;
          }
        },
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12), // Increased padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Increased border radius
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 28), // Larger icon
          const SizedBox(width: 12), // Increased spacing
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14, // Increased font size
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16, // Increased font size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
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
    // TODO: Implement event handling if needed
    _logger.i('Received event: ${event.runtimeType}');
  }
}
