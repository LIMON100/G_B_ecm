import 'package:ecom_flutter/custom/box_decorations.dart';
import 'package:ecom_flutter/custom/btn.dart';
import 'package:ecom_flutter/custom/enum_classes.dart';
import 'package:ecom_flutter/custom/lang_text.dart';
import 'package:ecom_flutter/custom/toast_component.dart';
import 'package:ecom_flutter/helpers/shared_value_helper.dart';
import 'package:ecom_flutter/helpers/shimmer_helper.dart';
import 'package:ecom_flutter/helpers/system_config.dart';
import 'package:ecom_flutter/my_theme.dart';
import 'package:ecom_flutter/repositories/cart_repository.dart';
import 'package:ecom_flutter/repositories/coupon_repository.dart';
import 'package:ecom_flutter/repositories/payment_repository.dart';
import 'package:ecom_flutter/screens/order_list.dart';
import 'package:ecom_flutter/screens/payment_method_screen/amarpay_screen.dart';
import 'package:ecom_flutter/screens/payment_method_screen/bkash_screen.dart';
import 'package:ecom_flutter/screens/payment_method_screen/flutterwave_screen.dart';
import 'package:ecom_flutter/screens/payment_method_screen/iyzico_screen.dart';
import 'package:ecom_flutter/screens/payment_method_screen/khalti_screen.dart';
import 'package:ecom_flutter/screens/payment_method_screen/my_fatoora_screen.dart';
import 'package:ecom_flutter/screens/payment_method_screen/nagad_screen.dart';
import 'package:ecom_flutter/screens/payment_method_screen/offline_screen.dart';
import 'package:ecom_flutter/screens/payment_method_screen/online_pay.dart';
import 'package:ecom_flutter/screens/payment_method_screen/payfast_screen.dart';
import 'package:ecom_flutter/screens/payment_method_screen/paypal_screen.dart';
import 'package:ecom_flutter/screens/payment_method_screen/paystack_screen.dart';
import 'package:ecom_flutter/screens/payment_method_screen/paytm_screen.dart';
import 'package:ecom_flutter/screens/payment_method_screen/phonepay_screen.dart';
import 'package:ecom_flutter/screens/payment_method_screen/razorpay_screen.dart';
import 'package:ecom_flutter/screens/payment_method_screen/sslcommerz_screen.dart';
import 'package:ecom_flutter/screens/payment_method_screen/stripe_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:toast/toast.dart';

class Checkout extends StatefulWidget {
  int? order_id; // only need when making manual payment from order details
  String list;
  //final OffLinePaymentFor offLinePaymentFor;
  final PaymentFor? paymentFor;
  final double rechargeAmount;
  String? title;
  var packageId;

  Checkout(
      {Key? key,
        this.order_id = 0,
        this.paymentFor,
        this.list = "both",
        //this.offLinePaymentFor,
        this.rechargeAmount = 0.0,
        this.title,
        this.packageId = 0})
      : super(key: key);

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _ccvController = TextEditingController();
  String? _selectedMonth;
  String? _selectedYear;

  List<String> months = List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> years = List.generate(10, (index) => (DateTime.now().year + index).toString());

  var _paymentTypeList = [];
  bool _isInitial = true;

  var _selected_payment_method_index = 0;
  String? _selected_payment_method = "";
  String? _selected_payment_method_key = "";

  ScrollController _mainScrollController = ScrollController();
  TextEditingController _couponController = TextEditingController();
  String? _totalString = ". . .";
  double? _grandTotalValue = 0.00;
  String? _subTotalString = ". . .";
  String? _taxString = ". . .";
  String _shippingCostString = ". . .";
  String? _discountString = ". . .";
  String _used_coupon_code = "";
  bool? _coupon_applied = false;
  late BuildContext loadingcontext;
  String payment_type = "cart_payment";
  String? _title;

  bool _showCardSection = false;

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderNameController.dispose();
    _ccvController.dispose();
    super.dispose();
  }

  fetchAll() {
    fetchList();

    if (is_logged_in.$) {
      if (widget.paymentFor != PaymentFor.Order) {
        _grandTotalValue = widget.rechargeAmount;
        payment_type = widget.paymentFor == PaymentFor.WalletRecharge
            ? "wallet_payment"
            : "customer_package_payment";
      } else {
        fetchSummary();
      }
    }
  }

  fetchList() async {
    String mode = '';
    setState(() {
      mode = widget.paymentFor != PaymentFor.Order &&
          widget.paymentFor != PaymentFor.ManualPayment
          ? "wallet"
          : "order";
    });

    var paymentTypeResponseList = await PaymentRepository()
        .getPaymentResponseList(list: widget.list, mode: mode);
    _paymentTypeList.addAll(paymentTypeResponseList.map((e) => PaymentTypeItem.fromResponse(e)));

    //Add Card

    String cardImage = 'assets/credit_card.png'; // Your Local asset Path or any logo for card

    _paymentTypeList.add(
      PaymentTypeItem(
          "card",
          "Cards",
          "card",
          "assets/card_payment.png"
      ),
    );

    if (_paymentTypeList.length > 0) {
      _selected_payment_method = _paymentTypeList[0].payment_type;
      _selected_payment_method_key = _paymentTypeList[0].payment_type_key;
    }

    _isInitial = false;
    setState(() {});
  }

  fetchSummary() async {
    var cartSummaryResponse = await CartRepository().getCartSummaryResponse();

    if (cartSummaryResponse != null) {
      _subTotalString = cartSummaryResponse.sub_total;
      _taxString = cartSummaryResponse.tax;
      _shippingCostString = cartSummaryResponse.shipping_cost;
      _discountString = cartSummaryResponse.discount;
      _totalString = cartSummaryResponse.grand_total;
      _grandTotalValue = cartSummaryResponse.grand_total_value;
      _used_coupon_code = cartSummaryResponse.coupon_code ?? _used_coupon_code;
      _couponController.text = _used_coupon_code;
      _coupon_applied = cartSummaryResponse.coupon_applied;
      setState(() {});
    }
  }

  reset() {
    _paymentTypeList.clear();
    _isInitial = true;
    _selected_payment_method_index = 0;
    _selected_payment_method = "";
    _selected_payment_method_key = "";
    _showCardSection = false;
    setState(() {});

    reset_summary();
  }

  reset_summary() {
    _totalString = ". . .";
    _grandTotalValue = 0.00;
    _subTotalString = ". . .";
    _taxString = ". . .";
    _shippingCostString = ". . .";
    _discountString = ". . .";
    _used_coupon_code = "";
    _couponController.text = _used_coupon_code!;
    _coupon_applied = false;

    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchAll();
  }

  onPopped(value) {
    reset();
    fetchAll();
  }

  onCouponApply() async {
    var coupon_code = _couponController.text.toString();
    if (coupon_code == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_coupon_code,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var couponApplyResponse =
    await CouponRepository().getCouponApplyResponse(coupon_code);
    if (couponApplyResponse.result == false) {
      ToastComponent.showDialog(couponApplyResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    reset_summary();
    fetchSummary();
  }

  onCouponRemove() async {
    var couponRemoveResponse =
    await CouponRepository().getCouponRemoveResponse();

    if (couponRemoveResponse.result == false) {
      ToastComponent.showDialog(couponRemoveResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    reset_summary();
    fetchSummary();
  }

  onPressPlaceOrderOrProceed() {
    if (_selected_payment_method == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.please_choose_one_option_to_pay,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }
    if (_grandTotalValue == 0.00) {
      ToastComponent.showDialog(AppLocalizations.of(context)!.nothing_to_pay,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    if (_selected_payment_method == "stripe_payment") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return StripeScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
        );
      })).then((value) {
        onPopped(value);
      });
    }
    if (_selected_payment_method == "aamarpay") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AmarpayScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "paypal_payment") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PaypalScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "razorpay") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return RazorpayScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "paystack") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PaystackScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "iyzico") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return IyzicoScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "bkash") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return BkashScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "nagad") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return NagadScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "sslcommerz_payment") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return SslCommerzScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "flutterwave") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return FlutterwaveScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "paytm") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PaytmScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "khalti") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return KhaltiScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "instamojo_payment") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return OnlinePay(
          title: LangText(context).local.pay_with_instamojo,
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "payfast") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PayfastScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "phonepe") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PhonepayScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "myfatoorah") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MyFatooraScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "wallet_system") {
      pay_by_wallet();
    } else if (_selected_payment_method == "cash_payment") {
      pay_by_cod();
    } else if (_selected_payment_method == "manual_payment" &&
        widget.paymentFor == PaymentFor.Order) {
      pay_by_manual_payment();
    } else if (_selected_payment_method == "manual_payment" &&
        (widget.paymentFor == PaymentFor.ManualPayment ||
            widget.paymentFor == PaymentFor.WalletRecharge ||
            widget.paymentFor == PaymentFor.PackagePay)) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return OfflineScreen(
          order_id: widget.order_id,
          paymentInstruction:
          _paymentTypeList[_selected_payment_method_index].details,
          offline_payment_id: _paymentTypeList[_selected_payment_method_index]
              .offline_payment_id,
          rechargeAmount: widget.rechargeAmount,
          offLinePaymentFor: widget.paymentFor,
          paymentMethod: _paymentTypeList[_selected_payment_method_index].name,
          packageId: widget.packageId,
//          offLinePaymentFor: widget.offLinePaymentFor,
        );
      })).then((value) {
        onPopped(value);
      });
    }
  }

  //Function for formatting the card
  String _formatCardNumber(String input) {
    input = input.replaceAll(RegExp(r'\s+'), ''); // Remove non-digit
    if (input.length > 16) {
      input = input.substring(0, 16); //To not crash everything by not allowing over 16
    }
    String formatted = '';
    for (int i = 0; i < input.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += input[i];
    }
    return formatted;
  }

  //Set selection so the numbers doesn't overlap each other when formatting the card
  void _onCardNumberChanged(String value) {
    final cursorPosition = _cardNumberController.selection.base.offset;

    final formattedValue = _formatCardNumber(value);

    _cardNumberController.value = TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(
        offset: cursorPosition + (formattedValue.length - value.length),
      ),
    );
  }

  pay_by_wallet() async {
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponseFromWallet(
        _selected_payment_method_key, _grandTotalValue);

    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return OrderList(from_checkout: true);
    }));
  }

  pay_by_cod() async {
    loading();
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponseFromCod(_selected_payment_method_key);
    Navigator.of(loadingcontext).pop();
    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return OrderList(from_checkout: true);
    }));
  }

  pay_by_manual_payment() async {
    loading();
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponseFromManualPayment(_selected_payment_method_key);
    Navigator.pop(loadingcontext);
    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return OrderList(from_checkout: true);
    }));
  }

  onPaymentMethodItemTap(index) {
    setState(() {
      _selected_payment_method_index = index;
      if (index < _paymentTypeList.length) {
        _selected_payment_method = _paymentTypeList[index].payment_type;
        _selected_payment_method_key = _paymentTypeList[index].payment_type_key;
      }
      else{
        _selected_payment_method = "card";
        _selected_payment_method_key = "card";
      }

      // Show or hide the card section based on selection
      _showCardSection = _selected_payment_method == "card";
    });
  }

  onPressDetails() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
        EdgeInsets.only(top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
        content: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 16.0),
          child: Container(
            height: 150,
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            AppLocalizations.of(context)!.subtotal_all_capital,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Spacer(),
                        Text(
                          SystemConfig.systemCurrency != null
                              ? _subTotalString!.replaceAll(
                              SystemConfig.systemCurrency!.code!,
                              SystemConfig.systemCurrency!.symbol!)
                              : _subTotalString!,
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            AppLocalizations.of(context)!.tax_all_capital,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Spacer(),
                        Text(
                          SystemConfig.systemCurrency != null
                              ? _taxString!.replaceAll(
                              SystemConfig.systemCurrency!.code!,
                              SystemConfig.systemCurrency!.symbol!)
                              : _taxString!,
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            AppLocalizations.of(context)!
                                .shipping_cost_all_capital,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Spacer(),
                        Text(
                          SystemConfig.systemCurrency != null
                              ? _shippingCostString!.replaceAll(
                              SystemConfig.systemCurrency!.code!,
                              SystemConfig.systemCurrency!.symbol!)
                              : _shippingCostString!,
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            AppLocalizations.of(context)!.discount_all_capital,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Spacer(),
                        Text(
                          SystemConfig.systemCurrency != null
                              ? _discountString!.replaceAll(
                              SystemConfig.systemCurrency!.code!,
                              SystemConfig.systemCurrency!.symbol!)
                              : _discountString!,
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
                Divider(),
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            AppLocalizations.of(context)!
                                .grand_total_all_capital,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Spacer(),
                        Text(
                          SystemConfig.systemCurrency != null
                              ? _totalString!.replaceAll(
                              SystemConfig.systemCurrency!.code!,
                              SystemConfig.systemCurrency!.symbol!)
                              : _totalString!,
                          style: TextStyle(
                            // color: Colors.orange,
                              color: Colors.black,

                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
        actions: [
          Btn.basic(
            child: Text(
              AppLocalizations.of(context)!.close_all_lower,
              style: TextStyle(color: MyTheme.medium_grey),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
      app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: buildAppBar(context),
          bottomNavigationBar: buildBottomAppBar(context),
          body: Stack(
            children: [
              RefreshIndicator(
                // color: Colors.orange,
                color: Colors.black,
                backgroundColor: Colors.white,
                onRefresh: _onRefresh,
                displacement: 0,
                child: CustomScrollView(
                  controller: _mainScrollController,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: buildPaymentMethodList(),
                        ),

                        if (_showCardSection) ...[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildCardInputForm(),
                          ),
                        ],

                        Container(
                          height: 140,
                        )
                      ]),
                    )
                  ],
                ),
              ),

              //Apply Coupon and order details container
              Align(
                alignment: Alignment.bottomCenter,
                child: widget.paymentFor == PaymentFor.WalletRecharge ||
                    widget.paymentFor == PaymentFor.PackagePay
                    ? Container()
                    : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,

                    /*border: Border(
                      top: BorderSide(color: MyTheme.light_grey,width: 1.0),
                    )*/
                  ),
                  height: widget.paymentFor == PaymentFor.ManualPayment
                      ? 80
                      : 140,
                  //color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        widget.paymentFor == PaymentFor.Order
                            ? Padding(
                          padding:
                          const EdgeInsets.only(bottom: 16.0),
                          child: buildApplyCouponRow(context),
                        )
                            : Container(),
                        grandTotalSection(),
                      ],
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  // Widget _buildCardInputForm() {
  //   return Card(
  //       elevation: 8,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       color: MyTheme.soft_accent_color, // Customize the card appearance
  //
  //       child: Padding(
  //       padding: const EdgeInsets.all(20.0),
  //   child: Form(
  //     key: _formKey,
  //     child: Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //     Text(
  //     "Card Information",
  //     style: TextStyle(
  //     fontSize: 18,
  //     fontWeight: FontWeight.bold,
  //     color: Colors.black
  //     ),
  //     ),
  //     SizedBox(height: 10),
  //     TextFormField(
  //     controller: _cardNumberController,
  //     decoration: InputDecoration(
  //     labelText: "Card Number",
  //     labelStyle: TextStyle(color: Colors.grey[800]),
  //     ),
  //     keyboardType: TextInputType.number,
  //     validator: (value) {
  //     if (value == null || value.isEmpty) {
  //     return "Please enter your card number";
  //     }
  //     return null;
  //     },
  //     ),
  //     SizedBox(height: 10),
  //     TextFormField(
  //     controller: _cardHolderNameController,
  //     decoration: InputDecoration(
  //     labelText: "Card Holder Name",
  //     labelStyle: TextStyle(color: Colors.grey[800]),
  //     ),
  //     validator: (value) {
  //     if (value == null || value.isEmpty) {
  //     return "Please enter card holder name";
  //     }
  //     return null;
  //     },
  //     ),
  //     SizedBox(height: 10),
  //     Row(
  //     children: [
  //     Expanded(
  //     child: DropdownButtonFormField<String>(
  //     decoration: InputDecoration(
  //     labelText: "Expiry Month",
  //     labelStyle: TextStyle(color: Colors.grey[800]),
  //     ),
  //     value: _selectedMonth,
  //     items: months.map((String value) {
  //     return DropdownMenuItem<String>(
  //     value: value,
  //     child: Text(value),
  //     );
  //     }).toList(),
  //     onChanged: (value) {
  //     setState(() {
  //     _selectedMonth = value;
  //     });
  //     },
  //     validator: (value) {
  //     if (value == null || value.isEmpty) {
  //     return "Please select expiry month";
  //     }
  //     return null;
  //     },
  //     ),
  //     ),
  //     SizedBox(width: 10),
  //     Expanded(
  //     child: DropdownButtonFormField<String>(
  //     decoration: InputDecoration(
  //     labelText: "Expiry Year",
  //     labelStyle: TextStyle(color: Colors.grey[800]),
  //     ),
  //     value: _selectedYear,
  //     items: years.map((String value) {
  //     return DropdownMenuItem<String>(
  //     value: value,
  //     child: Text(value),
  //     );
  //     }).toList(),
  //     onChanged: (value) {
  //     setState(() {
  //     _selectedYear = value;
  //     });
  //     },
  //     validator: (value) {
  //     if (value == null || value.isEmpty) {
  //     return "Please select expiry year";
  //     }
  //     return null;
  //     },
  //     ),
  //     ),
  //     ],
  //     ),
  //     SizedBox(height: 10),
  //     TextFormField(
  //     controller: _ccvController,
  //     decoration: InputDecoration(
  //     labelText: "CCV",
  //     labelStyle: TextStyle(color: Colors.grey[800]),
  //     ),
  //     keyboardType: TextInputType.number,
  //     maxLength: 3,
  //     validator: (value) {
  //     if (value == null || value.isEmpty) {
  //     return "Please enter CCV";
  //     }
  //     if (value.length != 3) {
  //     return "CCV must be 3 digits";
  //     }
  //     return null;
  //     },
  //     ),
  //   SizedBox(height: 20),
  //   ElevatedButton(
  //   onPressed: () {
  //   if (_formKey.currentState!.validate()) {
  //   // Here you can use the card details for further processing (e.g., API call)
  //
  //   showDialog(
  //   context: context,
  //   builder: (_) => AlertDialog(
  //   title: Text('Card Details'),
  //   content: Column(
  //   crossAxisAlignment: CrossAxisAlignment.start,
  //   mainAxisSize: MainAxisSize.min,
  //   children: [
  //   Text('Card Number: ${_cardNumberController.text}'),
  //   Text('Card Holder Name: ${_cardHolderNameController.text}'),
  //     Text('Expiry Date: $_selectedMonth/$_selectedYear'),
  //     Text('CCV: ${_ccvController.text}'),
  //   ],
  //   ),
  //     actions: [
  //       TextButton(
  //         onPressed: () {
  //           Navigator.of(context).pop(); // Close the dialog
  //         },
  //         child: Text("OK"),
  //       ),
  //     ],
  //   ),
  //   );
  //   }
  //   },
  //     child: Text("Save Card",style: TextStyle(
  //         color: Colors.black
  //     ),),
  //   ),
  //   ],
  //   ),
  //   ),
  //       ),
  //   );
  // }

  Widget _buildCardInputForm() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: MyTheme.soft_accent_color, // Customize the card appearance
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Card Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '4444 3333 2222 1111',
                  labelStyle: TextStyle(color: Colors.grey[800]),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(19),
                ],
                onChanged: _onCardNumberChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your card number";
                  }
                  if (value.replaceAll(' ', '').length != 16) {
                    return "Card number must be 16 digits";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _cardHolderNameController,
                decoration: InputDecoration(
                  labelText: "Card Holder Name",
                  labelStyle: TextStyle(color: Colors.grey[800]),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter card holder name";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Expiry Month",
                        labelStyle: TextStyle(color: Colors.grey[800]),
                      ),
                      value: _selectedMonth,
                      items: months.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMonth = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select expiry month";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Expiry Year",
                        labelStyle: TextStyle(color: Colors.grey[800]),
                      ),
                      value: _selectedYear,
                      items: years.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select expiry year";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _ccvController,
                decoration: InputDecoration(
                  labelText: "CCV",
                  labelStyle: TextStyle(color: Colors.grey[800]),
                ),
                keyboardType: TextInputType.number,
                maxLength: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter CCV";
                  }
                  if (value.length != 3) {
                    return "CCV must be 3 digits";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () {
              //     if (_formKey.currentState!.validate()) {
              //       // Here you can use the card details for further processing (e.g., API call)
              //       showDialog(
              //         context: context,
              //         builder: (_) => AlertDialog(
              //           title: Text('Card Details'),
              //           content: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             mainAxisSize: MainAxisSize.min,
              //             children: [
              //               Text('Card Number: ${_cardNumberController.text}'),
              //               Text('Card Holder Name: ${_cardHolderNameController.text}'),
              //               Text('Expiry Date: $_selectedMonth/$_selectedYear'),
              //               Text('CCV: ${_ccvController.text}'),
              //             ],
              //           ),
              //           actions: [
              //             TextButton(
              //               onPressed: () {
              //                 Navigator.of(context).pop(); // Close the dialog
              //               },
              //               child: Text("OK"),
              //             ),
              //           ],
              //         ),
              //       );
              //     }
              //   },
              //   child: Text(
              //     "Save Card",
              //     style: TextStyle(
              //       color: Colors.black,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Row buildApplyCouponRow(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 42,
          width: (MediaQuery.of(context).size.width - 32) * (2 / 3),
          child: TextFormField(
            controller: _couponController,
            readOnly: _coupon_applied!,
            autofocus: false,
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enter_coupon_code,
                hintStyle:
                TextStyle(fontSize: 14.0, color: MyTheme.textfield_grey),
                enabledBorder: app_language_rtl.$!
                    ? OutlineInputBorder(
                  borderSide: BorderSide(
                      color: MyTheme.textfield_grey, width: 0.5),
                  borderRadius: const BorderRadius.only(
                    topRight: const Radius.circular(8.0),
                    bottomRight: const Radius.circular(8.0),
                  ),
                )
                    : OutlineInputBorder(
                  borderSide: BorderSide(
                      color: MyTheme.textfield_grey, width: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(8.0),
                    bottomLeft: const Radius.circular(8.0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: MyTheme.medium_grey, width: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(8.0),
                    bottomLeft: const Radius.circular(8.0),
                  ),
                ),
                contentPadding: EdgeInsets.only(left: 16.0)),
          ),
        ),
        !_coupon_applied!
            ? Container(
          width: (MediaQuery.of(context).size.width - 32) * (1 / 3),
          height: 42,
          child: Btn.basic(
            minWidth: MediaQuery.of(context).size.width,
            // color: Colors.orange,
            color: Colors.orange,
            shape: app_language_rtl.$!
                ? RoundedRectangleBorder(
                borderRadius: const BorderRadius.only(
                  topLeft: const Radius.circular(8.0),
                  bottomLeft: const Radius.circular(8.0),
                ))
                : RoundedRectangleBorder(
                borderRadius: const BorderRadius.only(
                  topRight: const Radius.circular(8.0),
                  bottomRight: const Radius.circular(8.0),
                )),
            child: Text(
              AppLocalizations.of(context)!.apply_coupon_all_capital,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              onCouponApply();
            },
          ),
        )
            : Container(
          width: (MediaQuery.of(context).size.width - 32) * (1 / 3),
          height: 42,
          child: Btn.basic(
            minWidth: MediaQuery.of(context).size.width,
            // color: Colors.orange,
            color: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.only(
                  topRight: const Radius.circular(8.0),
                  bottomRight: const Radius.circular(8.0),
                )),
            child: Text(
              AppLocalizations.of(context)!.remove_ucf,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              onCouponRemove();
            },
          ),
        )
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        widget.title!,
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildPaymentMethodList() {
    if (_isInitial && _paymentTypeList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (_paymentTypeList.length > 0) {
      return SingleChildScrollView(
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 14,
            );
          },
          itemCount: _paymentTypeList.length,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: buildPaymentMethodItemCard(index),
            );
          },
        ),
      );
    } else if (!_isInitial && _paymentTypeList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
                AppLocalizations.of(context)!.no_payment_method_is_added,
                style: TextStyle(color: MyTheme.font_grey),
              )));
    }
  }

  GestureDetector buildPaymentMethodItemCard(index) {

    PaymentTypeItem item = _paymentTypeList[index];

    return GestureDetector(
      onTap: () {
        onPaymentMethodItemTap(index);
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            decoration: BoxDecorations.buildBoxDecoration_1().copyWith(
                border: Border.all(
                    color: _selected_payment_method_key ==
                        item.payment_type_key
                        ? Colors.orange
                        : MyTheme.light_grey,
                    width: _selected_payment_method_key ==
                        item.payment_type_key
                        ? 2.0
                        : 0.0)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      width: 100,
                      height: 100,
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child:
                          Image(
                            image: _getImageProvider(item), // Use a method to determine image source
                            fit: BoxFit.fitWidth,
                          ))),
                  Container(
                    width: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            item.title,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                height: 1.6,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: buildPaymentMethodCheckContainer(
                _selected_payment_method_key ==
                    item.payment_type_key),
          )
        ],
      ),
    );
  }

  ImageProvider _getImageProvider(PaymentTypeItem item) {
    // Determine if the image source is from a URL or local asset
    if (item.image.startsWith('http')) {
      // It's a URL (network image)
      return NetworkImage(item.image);
    } else {
      // It's a local asset image
      return AssetImage(item.image);
    }
  }

  Widget buildPaymentMethodCheckContainer(bool check) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 400),
      opacity: check ? 1 : 0,
      child: Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0), color: Colors.green),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(Icons.check, color: Colors.white, size: 10),
        ),
      ),
    );
    /* Visibility(
      visible: check,
      child: Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0), color: Colors.green),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(Icons.check, color: Colors.white, size: 10),
        ),
      ),
    );*/
  }

  BottomAppBar buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      child: Container(
        color: Colors.transparent,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Btn.minWidthFixHeight(
              minWidth: MediaQuery.of(context).size.width,
              height: 50,
              // color: Colors.orange,
              color: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Text(
                widget.paymentFor == PaymentFor.WalletRecharge
                    ? AppLocalizations.of(context)!.recharge_wallet_ucf
                    : widget.paymentFor == PaymentFor.ManualPayment
                    ? AppLocalizations.of(context)!.proceed_all_caps
                    : widget.paymentFor == PaymentFor.PackagePay
                    ? AppLocalizations.of(context)!.buy_package_ucf
                    : AppLocalizations.of(context)!
                    .place_my_order_all_capital,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                onPressPlaceOrderOrProceed();
              },
            )
          ],
        ),
      ),
    );
  }

  Widget grandTotalSection() {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: MyTheme.soft_accent_color),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                AppLocalizations.of(context)!.total_amount_ucf,
                style: TextStyle(color: MyTheme.font_grey, fontSize: 14),
              ),
            ),
            Visibility(
              visible: widget.paymentFor != PaymentFor.ManualPayment,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: InkWell(
                  onTap: () {
                    onPressDetails();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.see_details_all_lower,
                    style: TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                  widget.paymentFor == PaymentFor.ManualPayment
                      ? widget.rechargeAmount.toString()
                      : SystemConfig.systemCurrency != null
                      ? _totalString!.replaceAll(
                      SystemConfig.systemCurrency!.code!,
                      SystemConfig.systemCurrency!.symbol!)
                      : _totalString!,
                  style: TextStyle(
                    // color: Colors.orange,
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  loading() {
    showDialog(
        context: context,
        builder: (context) {
          loadingcontext = context;
          return AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 10,
                  ),
                  Text("${AppLocalizations.of(context)!.please_wait_ucf}"),
                ],
              ));
        });
  }
}

class PaymentTypeItem{

  String payment_type;
  String payment_type_key;
  String title;
  String image;

  PaymentTypeItem(this.payment_type, this.title, this.payment_type_key, this.image);

  PaymentTypeItem.fromResponse(dynamic response) :
        payment_type = response.payment_type ?? "",
        title = response.title ?? "",
        payment_type_key = response.payment_type_key ?? "",
        image = response.image ?? "" ;
}
