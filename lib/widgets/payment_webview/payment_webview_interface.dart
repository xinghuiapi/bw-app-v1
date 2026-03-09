import 'package:flutter/material.dart';

// Interface
abstract class PaymentWebViewBase extends StatefulWidget {
  final String url;
  final String title;

  const PaymentWebViewBase({super.key, required this.url, required this.title});
}
