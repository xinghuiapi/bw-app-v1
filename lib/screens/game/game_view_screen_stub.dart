import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
      title: widget.title ?? 'game.title'.tr(),
      errorText: 'game.unsupportedView'.tr(),
      child: const SizedBox.shrink(),
    );
  }
}
