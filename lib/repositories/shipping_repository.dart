import 'package:ecom_flutter/app_config.dart';
import 'package:ecom_flutter/data_model/carriers_response.dart';
import 'package:ecom_flutter/data_model/check_response_model.dart';
import 'package:ecom_flutter/data_model/delivery_info_response.dart';
import 'package:ecom_flutter/helpers/response_check.dart';
import 'package:ecom_flutter/helpers/shared_value_helper.dart';
import 'package:ecom_flutter/repositories/api-request.dart';


class ShippingRepository{
  Future<dynamic> getDeliveryInfo() async {
    String url =
    ("${AppConfig.BASE_URL}/delivery-info");
    print(url.toString());
    final response = await ApiRequest.get(
      url:url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );

    bool checkResult = ResponseCheck.apply(response.body);

    if(!checkResult)
      return responseCheckModelFromJson(response.body);


    return deliveryInfoResponseFromJson(response.body);
  }

}