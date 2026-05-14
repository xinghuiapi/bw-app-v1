import 'package:flutter/material.dart';
import 'search_panel.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SearchPanel(onClose: () => Navigator.of(context).pop()),
    );
  }
}
