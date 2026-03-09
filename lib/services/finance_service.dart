import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:my_flutter_app/api/dio_client.dart';
import 'package:my_flutter_app/models/api_response.dart';
import 'package:my_flutter_app/models/finance_models.dart';

class FinanceService {
  /// 获取一级分类列表
  /// 接口: /api/interface/class
  static Future<ApiResponse<List<DepositCategory>>> getPrimaryCategories() async {
    try {
      final response = await api.post('/interface/class');
      
      return ApiResponse<List<DepositCategory>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((e) => DepositCategory.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取转账分类列表（二级分类）
  /// 接口: /api/interface/list
  static Future<ApiResponse<List<TransferCategory>>> getTransferCategories(String code) async {
    try {
      final response = await api.post('/interface/list', data: {'code': code});
      
      return ApiResponse<List<TransferCategory>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((e) => TransferCategory.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取充值分类
  /// 接口: /api/deposit/class
  static Future<ApiResponse<List<DepositCategory>>> getDepositCategories() async {
    try {
      final response = await api.post('/deposit/class');
      
      return ApiResponse<List<DepositCategory>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((e) => DepositCategory.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取充值通道
  /// 接口: /api/deposit/getlist
  static Future<ApiResponse<List<DepositChannel>>> getDepositChannels(int categoryId) async {
    try {
      final response = await api.post('/deposit/getlist', data: {'id': categoryId});
      
      return ApiResponse<List<DepositChannel>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((e) => DepositChannel.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 提交充值申请
  /// 接口: /api/recharge/order
  static Future<ApiResponse<DepositOrderResponse>> submitRecharge(DepositOrderRequest request) async {
    try {
      final response = await api.post('/recharge/order', data: request.toJson());
      
      return ApiResponse<DepositOrderResponse>.fromJson(
        response.data,
        (json) {
          if (json is Map<String, dynamic>) {
            return DepositOrderResponse.fromJson(json);
          }
          return DepositOrderResponse();
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取充值订单详情
  /// 接口: /api/recharge/details
  static Future<ApiResponse<RechargeDetail>> getRechargeDetails(int orderId) async {
    try {
      final response = await api.post('/recharge/details', data: {'id': orderId});
      
      return ApiResponse<RechargeDetail>.fromJson(
        response.data,
        (json) {
          if (json is Map<String, dynamic>) {
            return RechargeDetail.fromJson(json);
          }
          throw Exception('Invalid data format');
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 取消充值订单
  /// 接口: /api/recharge/cancel
  static Future<ApiResponse<void>> cancelRecharge(int orderId, {String note = 'User Cancelled'}) async {
    try {
      final response = await api.post('/recharge/cancel', data: {'id': orderId, 'note': note});
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 上传充值凭证
  /// 接口: /api/recharge/img
  static Future<ApiResponse<void>> uploadRechargeImage(int orderId, String imgUrl) async {
    try {
      final response = await api.post('/recharge/img', data: {'id': orderId, 'img': imgUrl});
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取收款方式列表
  /// 接口: /api/drawing/getlist
  static Future<ApiResponse<List<PaymentMethod>>> getPaymentMethods() async {
    try {
      final response = await api.post('/drawing/getlist');
      
      return ApiResponse<List<PaymentMethod>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取支持的卡片类型
  /// 接口: /api/bank/getlist
  /// type: 1银行卡，2虚拟币，3支付宝
  static Future<ApiResponse<List<BankType>>> getBankTypes(int type) async {
    try {
      final response = await api.post('/bank/getlist', data: {'type': type});
      
      return ApiResponse<List<BankType>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((e) => BankType.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 绑定收款方式
  /// 接口: /api/member_bank/binding
  static Future<ApiResponse<void>> bindPaymentMethod(BindPaymentRequest request) async {
    try {
      final response = await api.post('/member_bank/binding', data: request.toJson());
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 删除收款方式
  /// 接口: /api/member_bank/delete
  static Future<ApiResponse<void>> deletePaymentMethod(int id) async {
    try {
      final response = await api.post('/member_bank/delete', data: {'id': id});
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 提交提现申请
  /// 接口: /api/drawing/order
  static Future<ApiResponse<void>> submitWithdraw(WithdrawRequest request) async {
    try {
      final response = await api.post('/drawing/order', data: request.toJson());
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取交易记录
  /// 接口: /api/trade/record
  static Future<ApiResponse<List<TradeRecord>>> getTradeRecord(TradeRecordRequest request) async {
    try {
      final response = await api.post('/trade/record', data: request.toJson());
      
      return ApiResponse<List<TradeRecord>>.fromJson(
        response.data,
        (json) {
          // 假设分页数据在 data.data 中
          if (json is Map<String, dynamic> && json.containsKey('data') && json['data'] is List) {
            return (json['data'] as List).map((e) => TradeRecord.fromJson(e as Map<String, dynamic>)).toList();
          }
          if (json is List) {
            return json.map((e) => TradeRecord.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取转账记录列表
  /// 接口: /api/transfers_log/getlist
  static Future<ApiResponse<List<TransferRecord>>> getTransferRecords({int page = 1, int size = 20}) async {
    try {
      final response = await api.post('/transfers_log/getlist', data: {'page': page, 'size': size});
      
      return ApiResponse<List<TransferRecord>>.fromJson(
        response.data,
        (json) {
          if (json is Map<String, dynamic> && json.containsKey('data') && json['data'] is List) {
            return (json['data'] as List).map((e) => TransferRecord.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取返水记录列表
  /// 接口: /api/member_fs_log/getlist
  static Future<ApiResponse<List<RebateRecord>>> getRebateRecords({
    int page = 1,
    int size = 20,
    String? code,
    String? startDate,
    String? endDate,
    int? status,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'page': page,
        'size': size,
      };
      if (code != null && code.isNotEmpty) data['code'] = code;
      if (startDate != null && startDate.isNotEmpty) data['start_date'] = startDate;
      if (endDate != null && endDate.isNotEmpty) data['end_date'] = endDate;
      if (status != null) data['status'] = status;

      final response = await api.post('/member_fs_log/getlist', data: data);
      
      return ApiResponse<List<RebateRecord>>.fromJson(
        response.data,
        (json) {
          if (json is Map<String, dynamic> && json.containsKey('data') && json['data'] is List) {
            return (json['data'] as List).map((e) => RebateRecord.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 领取返水
  /// 接口: /api/member_fs_log/claim
  static Future<ApiResponse<dynamic>> claimRebate(int id) async {
    try {
      final response = await api.post('/member_fs_log/claim', data: {'id': id});
      return ApiResponse.fromJson(response.data, (json) => json);
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取账变记录列表
  /// 接口: /api/money_log/getlist
  static Future<ApiResponse<List<MoneyLog>>> getMoneyLogList({
    int page = 1,
    int size = 20,
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'page': page,
        'size': size,
      };
      if (type != null) data['type'] = type;
      if (startDate != null) data['start_date'] = startDate;
      if (endDate != null) data['end_date'] = endDate;

      final response = await api.post('/money_log/getlist', data: data);
      
      return ApiResponse<List<MoneyLog>>.fromJson(
        response.data,
        (json) {
          if (json is Map<String, dynamic> && json.containsKey('data') && json['data'] is List) {
            return (json['data'] as List).map((e) => MoneyLog.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取下注记录列表
  /// 接口: /api/gamerecord/getlist
  static Future<ApiResponse<List<BettingRecord>>> getBettingRecords({
    int page = 1,
    int size = 20,
    int? status,
    String? code,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'page': page,
        'size': size,
      };
      if (status != null) data['status'] = status;
      if (code != null && code.isNotEmpty) data['code'] = code;
      if (startDate != null && startDate.isNotEmpty) data['start_date'] = startDate;
      if (endDate != null && endDate.isNotEmpty) data['end_date'] = endDate;

      final response = await api.post('/gamerecord/getlist', data: data);
      
      return ApiResponse<List<BettingRecord>>.fromJson(
        response.data,
        (json) {
          if (json is Map<String, dynamic> && json.containsKey('data') && json['data'] is List) {
            return (json['data'] as List).map((e) => BettingRecord.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取游戏余额
  /// 接口: /api/game/balance
  /// id: 分类代码 (如 'LIVE', 'SLOT') 或平台 ID
  static Future<ApiResponse<List<GameBalance>>> getGameBalance(dynamic id) async {
    try {
      final response = await api.post('/game/balance', data: {'id': id});
      
      return ApiResponse<List<GameBalance>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((e) => GameBalance.fromJson(e as Map<String, dynamic>)).toList();
          }
          if (json is Map<String, dynamic>) {
             // 某些情况下可能返回单个对象的 Map，将其放入 List
             return [GameBalance.fromJson(json)];
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 转入游戏
  /// 接口: /api/game/deposit
  static Future<ApiResponse<void>> depositToGame(int id, double money) async {
    try {
      final response = await api.post('/game/deposit', data: {'id': id, 'money': money});
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 转出游戏
  /// 接口: /api/game/withdrawal
  static Future<ApiResponse<void>> withdrawFromGame(int id, double money) async {
    try {
      final response = await api.post('/game/withdrawal', data: {'id': id, 'money': money});
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 手动/免转切换
  /// 接口: /api/game/transfer
  /// type: 1手动，2免转
  static Future<ApiResponse<void>> transferMode(int type) async {
    try {
      final response = await api.post('/game/transfer', data: {'type': type});
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 一键回收
  /// 接口: /api/game/all_trans
  static Future<ApiResponse<void>> allTrans() async {
    try {
      final response = await api.post('/game/all_trans');
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }
  
  /// 上传图片文件
  /// 接口: /api/img/save
  static Future<ApiResponse<String>> uploadImage(dynamic file) async {
    try {
      FormData formData;
      
      if (file is List<int> || file is Uint8List) {
        // 字节数据 (Web/Mobile)
        formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(file as List<int>, filename: 'upload.png'),
        });
      } else if (file is String) {
        // 文件路径 (Mobile/Desktop)
        String fileName = file.split('/').last;
        formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(file, filename: fileName),
        });
      } else {
        return ApiResponse(code: -1, msg: 'Invalid file type');
      }

      final response = await api.post('/img/save', data: formData);
      
      return ApiResponse<String>.fromJson(
        response.data,
        (json) {
          String? url;
          if (json is Map<String, dynamic>) {
            if (json.containsKey('url')) {
              url = json['url'];
            } else if (json.containsKey('data') && json['data'] is Map) {
              final innerData = json['data'] as Map;
              if (innerData.containsKey('url')) {
                url = innerData['url'];
              }
            }
          }
          
          if (url != null) {
            // 修复服务端返回的多余斜杠 (例如 ///)
            // 使用正则将多个斜杠替换为单个斜杠，但保留协议头
            if (url.startsWith('http://')) {
              final part = url.substring(7);
              url = 'http://${part.replaceAll(RegExp(r'/+'), '/')}';
            } else if (url.startsWith('https://')) {
              final part = url.substring(8);
              url = 'https://${part.replaceAll(RegExp(r'/+'), '/')}';
            } else {
               url = url.replaceAll(RegExp(r'/+'), '/');
            }
            return url;
          }
          
          return json.toString();
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }
}
