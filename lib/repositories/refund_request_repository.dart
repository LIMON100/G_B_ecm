import 'dart:convert';

import 'package:ecom_flutter/app_config.dart';
import 'package:ecom_flutter/data_model/check_response_model.dart';
import 'package:ecom_flutter/data_model/refund_request_response.dart';
import 'package:ecom_flutter/data_model/refund_request_send_response.dart';
import 'package:ecom_flutter/helpers/response_check.dart';
import 'package:ecom_flutter/helpers/shared_value_helper.dart';
import 'package:ecom_flutter/repositories/api-request.dart';

import '../helpers/main_helpers.dart';

class RefundRequestRepository {
  Future<dynamic> getRefundRequestListResponse({page = 1}) async {
    Map<String, String> header = commonHeader;

    header.addAll(authHeader);
    header.addAll(currencyHeader);

    String url = ("${AppConfig.BASE_URL}/refund-request/get-list?page=$page");
    final response = await ApiRequest.get(
      url: url,
      headers: header,
    );
    bool checkResult = ResponseCheck.apply(response.body);

    if (!checkResult) return responseCheckModelFromJson(response.body);

    return refundRequestResponseFromJson(response.body);
  }

  Future<dynamic> getRefundRequestSendResponse(
      {required int? id, required String reason}) async {
    var post_body = jsonEncode({
      "id": "${id}",
      "reason": "${reason}",
    });

    String url = ("${AppConfig.BASE_URL}/refund-request/send");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        body: post_body);
    bool checkResult = ResponseCheck.apply(response.body);

    if (!checkResult) return responseCheckModelFromJson(response.body);

    return refundRequestSendResponseFromJson(response.body);
  }
}
