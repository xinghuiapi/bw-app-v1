import 'package:flutter/material.dart';

class GameViewScreen extends StatelessWidget {
  const GameViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('游戏'),
      ),
      body: const Center(
        child: Text('游戏展示页面'),
      ),
    );
  }
}
