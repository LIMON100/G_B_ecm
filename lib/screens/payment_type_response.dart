class PaymentTypeResponse {
  String payment_type;
  String payment_type_key;
  String title;
  String image;

  PaymentTypeResponse({
    required this.payment_type,
    required this.payment_type_key,
    required this.title,
    required this.image,
  });

  factory PaymentTypeResponse.fromJson(Map<String, dynamic> json) {
    return PaymentTypeResponse(
      payment_type: json['payment_type'] as String,
      title: json['title'] as String,
      payment_type_key: json['payment_type_key'] as String,
      image: json['image'] as String,
    );
  }
}