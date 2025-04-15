import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Required for LatLng

class MapOverlay extends StatelessWidget {
  final VoidCallback onClose;

  const MapOverlay({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5), // Semi-transparent background
        child: Center(
          child: Container(
            width:
                MediaQuery.of(context).size.width * 0.9, // 90% of screen width
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: const Color(0xFF1F1638),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF5C4EB4), width: 4.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: const LatLng(25.0340, 121.5645),
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.volticar',
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close,
                        color: Color(0xFF5C4EB4), size: 30),
                    onPressed: onClose,
                    tooltip: '關閉地圖',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
