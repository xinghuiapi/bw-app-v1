import 'package:flutter/material.dart';

class CardPackagesScreen extends StatelessWidget {
  const CardPackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的卡包'),
      ),
      body: const Center(
        child: Text('我的卡包页面'),
      ),
    );
  }
}
