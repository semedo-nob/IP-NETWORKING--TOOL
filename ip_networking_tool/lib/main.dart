import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const IpNetworkingTool());
}

class IpNetworkingTool extends StatelessWidget {
  const IpNetworkingTool({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IP Networking Tool',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}