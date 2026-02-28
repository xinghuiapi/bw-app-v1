import 'package:flutter/material.dart';

class WithdrawScreen extends StatelessWidget {
  const WithdrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('钱包提现'),
      ),
      body: const Center(
        child: Text('钱包提现页面'),
      ),
    );
  }
}
