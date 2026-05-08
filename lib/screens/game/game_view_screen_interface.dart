import 'package:flutter/material.dart';

abstract class GameViewScreenBase extends StatefulWidget {
  const GameViewScreenBase({super.key, required this.url, this.title});

  final String url;
  final String? title;
}
