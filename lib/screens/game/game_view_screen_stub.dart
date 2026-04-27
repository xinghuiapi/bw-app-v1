import 'package:flutter/material.dart';
import 'game_view_screen_interface.dart';

class GameViewScreen extends GameViewScreenBase {
  const GameViewScreen({super.key, required super.url, super.title});

  @override
  State<GameViewScreen> createState() => _GameViewScreenState();
}

class _GameViewScreenState extends State<GameViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title ?? '游戏'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Text('Platform not supported', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
