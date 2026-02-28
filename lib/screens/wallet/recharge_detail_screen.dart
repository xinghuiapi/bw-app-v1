import 'package:flutter/material.dart';

class RechargeDetailScreen extends StatelessWidget {
  const RechargeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('充值详情'),
      ),
      body: const Center(
        child: Text('充值详情页面'),
      ),
    );
  }
}
