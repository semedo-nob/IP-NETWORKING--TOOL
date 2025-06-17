import 'package:flutter/material.dart';
import 'input_tab.dart';
import 'output_tab.dart';
import 'export_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IP Networking Tool'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Input'),
            Tab(text: 'Output'),
            Tab(text: 'Export'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          InputTab(),
          OutputTab(),
          ExportTab(),
        ],
      ),
    );
  }
}