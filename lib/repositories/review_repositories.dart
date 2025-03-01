import 'package:ecom_flutter/app_config.dart';
import 'package:ecom_flutter/data_model/check_response_model.dart';
import 'package:ecom_flutter/helpers/response_check.dart';
import 'dart:convert';

import 'package:ecom_flutter/data_model/review_response.dart';
import 'package:ecom_flutter/data_model/review_submit_response.dart';

import 'package:ecom_flutter/helpers/shared_value_helper.dart';
import 'package:ecom_flutter/repositories/api-request.dart';
import 'package:flutter/foundation.dart';

class ReviewRepository {
  Future<dynamic> getReviewResponse( int? product_id,{page = 1}) async {

    String url=("${AppConfig.BASE_URL}/reviews/product/${product_id}?page=${page}");
    final response = await ApiRequest.get(
      url:url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}","App-Language": app_language.$!,
      },
    );
    bool checkResult = ResponseCheck.apply(response.body);

    if(!checkResult)
      return responseCheckModelFromJson(response.body);

    return reviewResponseFromJson(response.body);
  }

  Future<dynamic> getReviewSubmitResponse(
       int? product_id,
       int rating,
       String comment,
      ) async {
    var post_body = jsonEncode({
      "product_id": "${product_id}",
      "user_id": "${user_id.$}",
      "rating": "$rating",
      "comment": "$comment"
    });

    String url=("${AppConfig.BASE_URL}/reviews/submit");
    final response =
    await ApiRequest.post(url:url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}","App-Language": app_language.$!,
        },
        body: post_body);

    bool checkResult = ResponseCheck.apply(response.body);

    if(!checkResult)
      return responseCheckModelFromJson(response.body);


    return reviewSubmitResponseFromJson(response.body);
  }


}
