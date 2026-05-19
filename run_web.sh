#!/usr/bin/env bash
set -euo pipefail

dart run tool/prepare_web_fallback_fonts.dart
flutter run -d chrome --no-web-resources-cdn "$@"
