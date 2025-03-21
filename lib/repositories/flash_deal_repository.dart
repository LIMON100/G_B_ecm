import 'package:ecom_flutter/app_config.dart';
import 'package:ecom_flutter/data_model/flash_deal_response.dart';
import 'package:ecom_flutter/helpers/shared_value_helper.dart';
import 'package:ecom_flutter/repositories/api-request.dart';

import '../helpers/system_config.dart';

class FlashDealRepository {
  Future<FlashDealResponse> getFlashDeals() async {
    String url = ("${AppConfig.BASE_URL}/flash-deals");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
        
        
            
      },
    );

    return flashDealResponseFromJson(response.body.toString());
  }
}
