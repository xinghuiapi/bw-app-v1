// stub
import 'package:flutter/material.dart';
import 'payment_webview_interface.dart';

class PaymentWebView extends PaymentWebViewBase {
  const PaymentWebView({super.key, required super.url, required super.title});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: const Center(child: Text('Platform not supported')),
    );
  }
}
