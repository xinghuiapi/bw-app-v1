import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../providers/game/floating_game_provider.dart';
import '../../security/url_policy.dart';
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
    final initialUri = UrlPolicy.gameUri(widget.url);
    if (initialUri == null) {
      _isLoading = false;
      _errorText = 'game.invalidUrl'.tr();
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
                _errorText = 'game.gameLoadFailed'.tr();
              });
            }
          },
          onNavigationRequest: (request) {
            return UrlPolicy.isAllowedGameNavigation(request.url)
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(initialUri);
    _hasController = true;
  }

  @override
  Widget build(BuildContext context) {
    return GameViewShell(
      title: widget.title ?? 'game.title'.tr(),
      isLoading: _isLoading,
      errorText: _errorText,
      onReload: _errorText == null ? null : _reload,
      onMinimize: _minimize,
      child: !_hasController
          ? const SizedBox.shrink()
          : WebViewWidget(controller: _controller),
    );
  }

  void _reload() {
    final uri = UrlPolicy.gameUri(widget.url);
    if (uri == null || !_hasController) return;
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    _controller.loadRequest(uri);
  }

  void _minimize() {
    context.read<FloatingGameProvider>().minimize(
          url: widget.url,
          title: widget.title ?? 'game.title'.tr(),
        );
    context.canPop() ? context.pop() : context.go('/game');
  }
}
