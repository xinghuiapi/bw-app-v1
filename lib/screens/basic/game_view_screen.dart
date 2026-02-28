import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GameViewScreen extends StatelessWidget {
  final String url;
  final String? title;

  const GameViewScreen({
    super.key, 
    required this.url,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title ?? '游戏'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: kIsWeb
            ? _buildWebFrame()
            : _buildMobileFrame(), // 目前暂时都用 Html 插件处理，或者后期引入 webview_flutter
      ),
    );
  }

  Widget _buildWebFrame() {
    // Web 环境下，直接渲染 iframe
    return HtmlWidget(
      '<iframe src="$url" style="width:100%; height:100vh; border:none;"></iframe>',
      factoryBuilder: () => MyHtmlWidgetFactory(),
    );
  }

  Widget _buildMobileFrame() {
    // 移动端环境下，可以使用 webview_flutter，这里暂时也用 HtmlWidget 替代展示
    return HtmlWidget(
      '<iframe src="$url" style="width:100%; height:100vh; border:none;"></iframe>',
    );
  }
}

class MyHtmlWidgetFactory extends WidgetFactory {
  // const MyHtmlWidgetFactory(); // Error: super constructor is not const
  
  // 可以在这里自定义 iframe 的宽高或其他属性
}
