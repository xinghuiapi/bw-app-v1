import 'package:flutter/material.dart';

abstract class GameViewScreenBase extends StatefulWidget {
  final String url;
  final String? title;

  const GameViewScreenBase({super.key, required this.url, this.title});
}
