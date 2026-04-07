import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:my_flutter_app/providers/feedback_provider.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/models/home_data.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (image != null) {
        debugPrint('Picked image path: ${image.path}');
        ref.read(feedbackImageProvider.notifier).set(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('选择图片失败: $e')));
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final selectedTypeId = ref.read(selectedFeedbackTypeIdProvider);
    if (selectedTypeId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择反馈分类')));
      return;
    }

    final imagePath = ref.read(feedbackImageProvider);

    ref
        .read(feedbackSubmitProvider.notifier)
        .submit(selectedTypeId, _contentController.text, imagePath: imagePath);
  }

  @override
  Widget build(BuildContext context) {
    final feedbackTypesAsync = ref.watch(feedbackTypesProvider);
    final selectedTypeId = ref.watch(selectedFeedbackTypeIdProvider);
    final submitState = ref.watch(feedbackSubmitProvider);
    final selectedImagePath = ref.watch(feedbackImageProvider);

    // 监听提交成功
    ref.listen(feedbackSubmitProvider, (previous, next) {
      if (next.isSuccess) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('反馈提交成功')));
          context.pop();
        }
      } else if (next.error != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('提交失败: ${next.error}')));
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('问题反馈'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '反馈分类',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              feedbackTypesAsync.when(
                data: (types) => _buildCategorySelector(types, selectedTypeId),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('加载分类失败: $err'),
              ),
              const SizedBox(height: 24),
              const Text(
                '反馈内容',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: '请输入您的意见或建议 (不少于10个字)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withAlpha(13),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return '请输入反馈内容';
                  if (value.length < 10) return '反馈内容不能少于10个字';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                '上传图片 (可选)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildImagePicker(selectedImagePath),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: submitState.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: submitState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('提交反馈'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewImage(String imagePath) {
    // 优先检测是否为 URL (Web下 XFile.path 返回的是 blob: URL)
    if (imagePath.startsWith('blob:') || imagePath.startsWith('http')) {
      return WebSafeImage(
        imageUrl: imagePath,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorWidget: const Center(child: Icon(Icons.broken_image)),
      );
    }

    // 如果是 Web 环境，即使不是 blob 开头也强制使用 WebSafeImage (防止意外路径)
    if (kIsWeb) {
      return WebSafeImage(
        imageUrl: imagePath,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorWidget: const Center(child: Icon(Icons.broken_image)),
      );
    }

    // 只有在非 Web 且非 URL 格式时尝试使用 File
    return Image.file(
      File(imagePath),
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Center(child: Icon(Icons.broken_image)),
    );
  }

  Widget _buildImagePicker(String? imagePath) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(13),
          border: Border.all(color: Colors.grey.withAlpha(77)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: imagePath != null
            ? Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildPreviewImage(imagePath),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        ref.read(feedbackImageProvider.notifier).clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const Icon(
                Icons.add_a_photo_outlined,
                color: Colors.grey,
                size: 32,
              ),
      ),
    );
  }

  Widget _buildCategorySelector(List<FeedbackType> types, int? selectedId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withAlpha(77)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withAlpha(13),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          hint: const Text('请选择反馈分类'),
          value: selectedId,
          items: types.map((type) {
            return DropdownMenuItem<int>(
              value: type.id,
              child: Text(type.title ?? ''),
            );
          }).toList(),
          onChanged: (value) {
            ref.read(selectedFeedbackTypeIdProvider.notifier).set(value);
          },
        ),
      ),
    );
  }
}
