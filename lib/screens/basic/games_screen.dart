import 'package:flutter/material.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('游戏列表'),
      ),
      body: const Center(
        child: Text('游戏列表页面'),
      ),
    );
  }
}
