import 'package:flutter/material.dart';

typedef LibraryLoader = Future<void> Function();
typedef WidgetBuilder = Widget Function();

class DeferredWidget extends StatefulWidget {
  final LibraryLoader loader;
  final WidgetBuilder builder;
  final Widget? placeholder;

  const DeferredWidget({
    super.key,
    required this.loader,
    required this.builder,
    this.placeholder,
  });

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  Future<void>? _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return widget.builder();
        }
        return widget.placeholder ??
            const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
