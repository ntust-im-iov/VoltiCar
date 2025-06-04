import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cargo_model.dart';

class SetupView extends StatefulWidget {
  const SetupView({Key? key}) : super(key: key);

  @override
  State<SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<SetupView> {
  List<Cargo> warehouseCargo = [
    Cargo(name: 'Box 1', description: 'Fragile items', weight: 10),
    Cargo(name: 'Box 2', description: 'Electronics', weight: 15),
  ];

  List<Cargo> trunkCargo = [
    Cargo(name: 'Spare Tire', description: 'For emergencies', weight: 20),
    Cargo(name: 'Toolkit', description: 'Essential tools', weight: 5),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup'),
      ),
      body: Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: warehouseCargo.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(warehouseCargo[index].name),
                  subtitle: Text(warehouseCargo[index].description),
                  trailing: Text('${warehouseCargo[index].weight} kg'),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: trunkCargo.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(trunkCargo[index].name),
                  subtitle: Text(trunkCargo[index].description),
                  trailing: Text('${trunkCargo[index].weight} kg'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
