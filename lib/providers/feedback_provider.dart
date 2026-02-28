import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/home_data.dart';
import '../services/home_service.dart';
import 'language_provider.dart';

/// 反馈分类提供者
final feedbackTypesProvider = FutureProvider<List<FeedbackType>>((ref) async {
  final lang = ref.watch(languageProvider);
  final response = await HomeService.getFeedbackTypes(lang: lang);
  if (response.isSuccess) {
    return response.data ?? [];
  }
  return [];
});

/// 选中的反馈分类ID
class SelectedFeedbackTypeId extends Notifier<int?> {
  @override
  int? build() => null;
  void set(int? id) => state = id;
}
final selectedFeedbackTypeIdProvider = NotifierProvider<SelectedFeedbackTypeId, int?>(SelectedFeedbackTypeId.new);

/// 选中的反馈图片
class FeedbackImage extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? path) => state = path;
  void clear() => state = null;
}
final feedbackImageProvider = NotifierProvider<FeedbackImage, String?>(FeedbackImage.new);

/// 反馈提交状态
class FeedbackSubmitState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  FeedbackSubmitState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  FeedbackSubmitState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return FeedbackSubmitState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class FeedbackSubmitNotifier extends Notifier<FeedbackSubmitState> {
  @override
  FeedbackSubmitState build() => FeedbackSubmitState();

  Future<void> submit(int typeId, String content, {String? imagePath}) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    
    try {
      String? uploadedImageUrl;
      final lang = ref.read(languageProvider);
      
      // 如果有图片，先上传图片
      if (imagePath != null && imagePath.isNotEmpty) {
        final fileName = imagePath.split('/').last;
        final FormData formData = FormData();
        
        if (kIsWeb) {
          // Web 环境使用字节流
          final bytes = await XFile(imagePath).readAsBytes();
          formData.files.add(MapEntry(
            'file',
            MultipartFile.fromBytes(bytes, filename: fileName),
          ));
        } else {
          // 移动端环境使用文件路径
          formData.files.add(MapEntry(
            'file',
            await MultipartFile.fromFile(imagePath, filename: fileName),
          ));
        }
        
        formData.fields.add(const MapEntry('name', 'feedback'));
        
        final uploadResponse = await HomeService.uploadImage(formData, lang: lang);
        if (uploadResponse.isSuccess && uploadResponse.data != null) {
          uploadedImageUrl = uploadResponse.data;
        } else {
          state = state.copyWith(
            isLoading: false, 
            error: uploadResponse.msg ?? '图片上传失败',
          );
          return;
        }
      }

      // 提交反馈
      final response = await HomeService.submitFeedback(
        typeId, 
        content, 
        img: uploadedImageUrl,
        lang: lang,
      );
      
      if (response.isSuccess) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        // 成功后清除图片
        ref.read(feedbackImageProvider.notifier).clear();
      } else {
        state = state.copyWith(isLoading: false, error: response.msg ?? '提交失败');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = FeedbackSubmitState();
  }
}

final feedbackSubmitProvider = NotifierProvider<FeedbackSubmitNotifier, FeedbackSubmitState>(FeedbackSubmitNotifier.new);
