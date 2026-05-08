import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'game_view_screen_interface.dart';
import 'game_view_shell.dart';

class GameViewScreen extends GameViewScreenBase {
  const GameViewScreen({super.key, required super.url, super.title});

  @override
  State<GameViewScreen> createState() => _GameViewScreenState();
}

class _GameViewScreenState extends State<GameViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorText;
  bool _hasController = false;

  @override
  void initState() {
    super.initState();
    if (widget.url.trim().isEmpty || Uri.tryParse(widget.url.trim()) == null) {
      _isLoading = false;
      _errorText = '游戏地址无效';
      return;
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _errorText = null;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('Game WebView error: ${error.description}');
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorText = '游戏加载失败，请稍后重试';
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url.trim()));
    _hasController = true;
  }

  @override
  Widget build(BuildContext context) {
    return GameViewShell(
      title: widget.title ?? '游戏',
      isLoading: _isLoading,
      errorText: _errorText,
      onReload: _errorText == null ? null : _reload,
      child: !_hasController
          ? const SizedBox.shrink()
          : WebViewWidget(controller: _controller),
    );
  }

  void _reload() {
    final uri = Uri.tryParse(widget.url.trim());
    if (uri == null || !_hasController) return;
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    _controller.loadRequest(uri);
  }
}
