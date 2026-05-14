import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;
import 'package:easy_localization/easy_localization.dart';

import '../../providers/game/floating_game_provider.dart';
import 'game_view_screen_interface.dart';
import 'game_view_shell.dart';

class GameViewScreen extends GameViewScreenBase {
  const GameViewScreen({super.key, required super.url, super.title});

  @override
  State<GameViewScreen> createState() => _GameViewScreenState();
}

class _GameViewScreenState extends State<GameViewScreen> {
  late final String _viewId;
  late final bool _hasValidUrl;

  @override
  void initState() {
    super.initState();
    _hasValidUrl =
        widget.url.trim().isNotEmpty && Uri.tryParse(widget.url.trim()) != null;
    _viewId =
        'game-view-${widget.url.hashCode}-${DateTime.now().microsecondsSinceEpoch}';
    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final element = web.HTMLIFrameElement()
        ..src = _hasValidUrl ? widget.url.trim() : 'about:blank'
        ..allow = 'fullscreen; autoplay; picture-in-picture'
        ..setAttribute(
          'sandbox',
          'allow-same-origin allow-scripts allow-forms allow-popups allow-top-navigation-by-user-activation',
        )
        ..setAttribute('allowfullscreen', 'true')
        ..setAttribute('webkitallowfullscreen', 'true')
        ..setAttribute('mozallowfullscreen', 'true')
        ..style.border = 'none'
        ..style.height = '100%'
        ..style.width = '100%';
      return element;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameViewShell(
      title: widget.title ?? 'game.title'.tr(),
      errorText: _hasValidUrl ? null : 'game.invalidUrl'.tr(),
      onMinimize: _minimize,
      child: HtmlElementView(viewType: _viewId),
    );
  }

  void _minimize() {
    context.read<FloatingGameProvider>().minimize(
          url: widget.url,
          title: widget.title ?? 'game.title'.tr(),
        );
    context.canPop() ? context.pop() : context.go('/game');
  }
}
