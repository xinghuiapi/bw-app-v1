# 代码模式与命名约定

## **1. 文件命名约定**
- **模型文件**：`xxx_models.dart` 或 `user.dart`。
- **Provider 文件**：`xxx_provider.dart`。
- **Service 文件**：`xxx_service.dart`。
- **页面文件**：`xxx_screen.dart`。
- **组件文件**：`xxx_widget.dart`。

## **2. Riverpod Notifier 模式**
创建新的状态管理时，遵循以下模板：

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'my_notifier.g.dart';

@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  FutureOr<MyState> build() async {
    return const MyState();
  }

  Future<void> action() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 业务逻辑
      return newState;
    });
  }
}
```

## **3. API Service 模式**
所有 Service 必须使用 `DioClient` 实例：

```dart
class MyService {
  final DioClient _dio;
  MyService(this._dio);

  Future<ApiResponse<DataModel>> getData() async {
    final response = await _dio.get('/api/endpoint');
    return ApiResponse.fromJson(response.data, (json) => DataModel.fromJson(json));
  }
}
```

## **4. UI 页面结构**
页面应优先使用 `ConsumerWidget` 或 `ConsumerStatefulWidget`：

```dart
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(WidgetRef ref, BuildContext context) {
    final state = ref.watch(myProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Title')),
      body: state.when(
        data: (data) => _buildContent(data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorWidget(err),
      ),
    );
  }
}
```
