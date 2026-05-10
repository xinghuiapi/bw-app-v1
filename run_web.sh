#!/bin/bash

# 运行 Flutter Web 并指定国内 CanvasKit 镜像源
# 这可以解决 CanvasKit 加载失败的问题，并且支持热重载 (r) 和热重启 (R)

flutter run -d chrome --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://npm.elemecdn.com/canvaskit-wasm@0.39.1/bin/
