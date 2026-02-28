import 'package:flutter/material.dart';

class AddCardPackageScreen extends StatelessWidget {
  const AddCardPackageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加卡包'),
      ),
      body: const Center(
        child: Text('添加卡包页面'),
      ),
    );
  }
}
