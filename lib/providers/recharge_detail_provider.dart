import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/models/finance_models.dart';
import 'package:my_flutter_app/services/finance_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class RechargeDetailState {
  final bool isLoading;
  final bool isUploading;
  final String? errorMsg;
  final RechargeDetail? detail;
  final String? uploadedImageUrl;
  final Uint8List? localImageBytes;
  final String? localImagePath;

  RechargeDetailState({
    this.isLoading = false,
    this.isUploading = false,
    this.errorMsg,
    this.detail,
    this.uploadedImageUrl,
    this.localImageBytes,
    this.localImagePath,
  });

  RechargeDetailState copyWith({
    bool? isLoading,
    bool? isUploading,
    String? errorMsg,
    RechargeDetail? detail,
    String? uploadedImageUrl,
    Uint8List? localImageBytes,
    String? localImagePath,
  }) {
    return RechargeDetailState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      errorMsg: errorMsg, // Always set to provided or null if not provided
      detail: detail ?? this.detail,
      uploadedImageUrl: uploadedImageUrl ?? this.uploadedImageUrl,
      localImageBytes: localImageBytes ?? this.localImageBytes,
      localImagePath: localImagePath ?? this.localImagePath,
    );
  }
}

/// 使用标准的 Notifier 作为基类
class RechargeDetailNotifier extends Notifier<RechargeDetailState> {
  @override
  RechargeDetailState build() => RechargeDetailState();

  // 获取订单详情
  Future<void> fetchDetail(int orderId) async {
    state = state.copyWith(isLoading: true, errorMsg: null);

    try {
      final response = await FinanceService.getRechargeDetails(orderId);
      if (response.isSuccess) {
        // API 响应中没有 id，我们需要手动注入
        state = state.copyWith(
          detail: response.data?.copyWith(id: orderId),
          isLoading: false,
        );
      } else {
        state = state.copyWith(errorMsg: response.msg, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(errorMsg: e.toString(), isLoading: false);
    }
  }

  // 选择图片（不立即上传，仅本地显示）
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      try {
        // 读取图片字节数据用于显示（Web/Mobile 通用）
        final bytes = await image.readAsBytes();
        state = state.copyWith(
          localImageBytes: bytes,
          localImagePath: image.path,
          uploadedImageUrl: null, // 清除之前的 URL， because selected new image
          errorMsg: null,
        );
      } catch (e) {
        state = state.copyWith(errorMsg: '读取图片失败: $e');
      }
    }
  }

  // 取消订单
  Future<bool> cancelOrder(int orderId) async {
    state = state.copyWith(isLoading: true, errorMsg: null);
    try {
      final response = await FinanceService.cancelRecharge(orderId);
      if (response.isSuccess) {
        // 刷新订单详情
        await fetchDetail(orderId);
        return true;
      } else {
        state = state.copyWith(errorMsg: response.msg, isLoading: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(errorMsg: e.toString(), isLoading: false);
      return false;
    }
  }

  // 上传凭证（包含上传图片和提交申请两步）
  Future<bool> uploadReceipt(int orderId) async {
    if (state.localImageBytes == null && state.uploadedImageUrl == null) {
      state = state.copyWith(errorMsg: '请先选择图片');
      return false;
    }

    state = state.copyWith(isUploading: true, errorMsg: null);

    try {
      // 1. 如果有本地图片且未上传，先上传
      String? imageUrl = state.uploadedImageUrl;
      if (imageUrl == null && state.localImageBytes != null) {
        final uploadResponse = await FinanceService.uploadImage(state.localImageBytes!);
        if (uploadResponse.isSuccess && uploadResponse.data != null) {
          imageUrl = uploadResponse.data;
          state = state.copyWith(uploadedImageUrl: imageUrl);
        } else {
          state = state.copyWith(errorMsg: uploadResponse.msg, isUploading: false);
          return false;
        }
      }

      // 2. 提交凭证
      if (imageUrl != null) {
        final response = await FinanceService.uploadRechargeImage(
          orderId,
          imageUrl,
        );

        if (response.isSuccess) {
          state = state.copyWith(isUploading: false);
          // 提交成功后重新获取订单详情以更新 UI
          await fetchDetail(orderId);
          return true;
        } else {
          state = state.copyWith(errorMsg: response.msg, isUploading: false);
          return false;
        }
      }
      
      return false;
    } catch (e) {
      state = state.copyWith(errorMsg: e.toString(), isUploading: false);
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMsg: null);
  }
}

final rechargeDetailProvider = NotifierProvider.autoDispose<RechargeDetailNotifier, RechargeDetailState>(RechargeDetailNotifier.new);
