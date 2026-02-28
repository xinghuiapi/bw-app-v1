import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('站内通知'),
      ),
      body: const Center(
        child: Text('站内通知页面'),
      ),
    );
  }
}
