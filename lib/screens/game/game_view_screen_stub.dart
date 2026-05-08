import 'package:flutter/material.dart';

import 'game_view_screen_interface.dart';
import 'game_view_shell.dart';

class GameViewScreen extends GameViewScreenBase {
  const GameViewScreen({super.key, required super.url, super.title});

  @override
  State<GameViewScreen> createState() => _GameViewScreenState();
}

class _GameViewScreenState extends State<GameViewScreen> {
  @override
  Widget build(BuildContext context) {
    return GameViewShell(
      title: widget.title ?? '游戏',
      errorText: '当前平台暂不支持内嵌游戏',
      child: const SizedBox.shrink(),
    );
  }
}
