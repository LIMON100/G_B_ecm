import 'package:ecom_flutter/app_config.dart';
import 'package:ecom_flutter/data_model/addons_response.dart';
import 'package:ecom_flutter/data_model/offline_wallet_recharge_response.dart';
import 'package:ecom_flutter/repositories/api-request.dart';

class AddonsRepository {
  Future<List<AddonsListResponse>> getAddonsListResponse() async {
    // $();
    String url = ('${AppConfig.BASE_URL}/addon-list');
    final response = await ApiRequest.get(url: url);
    return addonsListResponseFromJson(response.body);
  }
}
