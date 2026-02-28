import 'package:flutter/material.dart';

class RechargeScreen extends StatelessWidget {
  const RechargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('钱包充值'),
      ),
      body: const Center(
        child: Text('钱包充值页面'),
      ),
    );
  }
}
