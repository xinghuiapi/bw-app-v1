import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'payment_webview_interface.dart';

class PaymentWebView extends PaymentWebViewBase {
  const PaymentWebView({super.key, required super.url, required super.title});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'payment-webview-${widget.url.hashCode}';

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
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: HtmlElementView(viewType: _viewId),
    );
  }
}
