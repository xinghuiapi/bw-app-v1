import 'package:flutter/material.dart';

class PasswordResetScreen extends StatelessWidget {
  const PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('重置密码'),
      ),
      body: const Center(
        child: Text('重置密码页面'),
      ),
    );
  }
}
