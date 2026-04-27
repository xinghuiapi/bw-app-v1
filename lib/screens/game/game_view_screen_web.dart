import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'game_view_screen_interface.dart';

class GameViewScreen extends GameViewScreenBase {
  const GameViewScreen({super.key, required super.url, super.title});

  @override
  State<GameViewScreen> createState() => _GameViewScreenState();
}

class _GameViewScreenState extends State<GameViewScreen> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'game-webview-${widget.url.hashCode}';

    // Register view factory
    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final element = web.HTMLIFrameElement()
        ..src = widget.url
        ..style.border = 'none'
        ..style.height = '100%'
        ..style.width = '100%';
      return element;
    });
  }

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
      body: HtmlElementView(viewType: _viewId),
    );
  }
}
