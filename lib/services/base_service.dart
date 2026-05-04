import '../api/dio_client.dart';

abstract class BaseService {
  const BaseService(this.client);

  final DioClient client;
}
