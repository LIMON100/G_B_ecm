// import 'package:ecom_flutter/custom/btn.dart';
// import 'package:ecom_flutter/custom/input_decorations.dart';
// import 'package:ecom_flutter/custom/intl_phone_input.dart';
// import 'package:ecom_flutter/custom/toast_component.dart';
// import 'package:ecom_flutter/helpers/shared_value_helper.dart';
// import 'package:ecom_flutter/my_theme.dart';
// import 'package:ecom_flutter/repositories/auth_repository.dart';
// import 'package:ecom_flutter/screens/password_otp.dart';
// import 'package:ecom_flutter/ui_elements/auth_ui.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
// import 'package:toast/toast.dart';
//
// import '../repositories/address_repository.dart';
//
// class PasswordForget extends StatefulWidget {
//   @override
//   _PasswordForgetState createState() => _PasswordForgetState();
// }
//
// class _PasswordForgetState extends State<PasswordForget> {
//   String _send_code_by = "email"; //phone or email
//   String initialCountry = 'US';
//   // PhoneNumber phoneCode = PhoneNumber(isoCode: 'US');
//   String? _phone = "";
//   var countries_code = <String?>[];
//   //controllers
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _phoneNumberController = TextEditingController();
//
//   @override
//   void initState() {
//     //on Splash Screen hide statusbar
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: [SystemUiOverlay.bottom]);
//     super.initState();
//     fetch_country();
//   }
//
//   @override
//   void dispose() {
//     //before going to other screen show statusbar
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
//     super.dispose();
//   }
//
//   onPressSendCode() async {
//     var email = _emailController.text.toString();
//
//     if (_send_code_by == 'email' && email == "") {
//       ToastComponent.showDialog(AppLocalizations.of(context)!.enter_email,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       return;
//     } else if (_send_code_by == 'phone' && _phone == "") {
//       ToastComponent.showDialog(
//           AppLocalizations.of(context)!.enter_phone_number,
//           gravity: Toast.center,
//           duration: Toast.lengthLong);
//       return;
//     }
//
//     var passwordForgetResponse = await AuthRepository()
//         .getPasswordForgetResponse(
//             _send_code_by == 'email' ? email : _phone, _send_code_by);
//
//     if (passwordForgetResponse.result == false) {
//       ToastComponent.showDialog(passwordForgetResponse.message!,
//           gravity: Toast.center, duration: Toast.lengthLong);
//     } else {
//       ToastComponent.showDialog(passwordForgetResponse.message!,
//           gravity: Toast.center, duration: Toast.lengthLong);
//
//       Navigator.push(context, MaterialPageRoute(builder: (context) {
//         return PasswordOtp(
//           verify_by: _send_code_by,
//         );
//       }));
//     }
//   }
//
//   fetch_country() async {
//     var data = await AddressRepository().getCountryList();
//     data.countries.forEach((c) => countries_code.add(c.code));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final _screen_height = MediaQuery.of(context).size.height;
//     final _screen_width = MediaQuery.of(context).size.width;
//     return AuthScreen.buildScreen(
//         context, "Forget Password!", buildBody(_screen_width, context));
//   }
//
//   Column buildBody(double _screen_width, BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         SizedBox(
//           height: 20,
//         ),
//         Container(
//           width: _screen_width * (3 / 4),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 4.0),
//                 child: Text(
//                   _send_code_by == "email"
//                       ? AppLocalizations.of(context)!.email_ucf
//                       : AppLocalizations.of(context)!.phone_ucf,
//                   style: TextStyle(
//                       color: Colors.orange, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               if (_send_code_by == "email")
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Container(
//                         height: 36,
//                         child: TextField(
//                           controller: _emailController,
//                           autofocus: false,
//                           decoration: InputDecorations.buildInputDecoration_1(
//                               hint_text: "johndoe@example.com"),
//                         ),
//                       ),
//                       otp_addon_installed.$
//                           ? GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   _send_code_by = "phone";
//                                 });
//                               },
//                               child: Text(
//                                 AppLocalizations.of(context)!
//                                     .or_send_code_via_phone_number,
//                                 style: TextStyle(
//                                     color: Colors.orange,
//                                     fontStyle: FontStyle.italic,
//                                     decoration: TextDecoration.underline),
//                               ),
//                             )
//                           : Container()
//                     ],
//                   ),
//                 )
//               else
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Container(
//                         height: 36,
//                         child: CustomInternationalPhoneNumberInput(
//                           countries: countries_code,
//                           onInputChanged: (PhoneNumber number) {
//                             //print(number.phoneNumber);
//                             setState(() {
//                               _phone = number.phoneNumber;
//                             });
//                           },
//                           onInputValidated: (bool value) {
//                             //print(value);
//                           },
//                           selectorConfig: SelectorConfig(
//                             selectorType: PhoneInputSelectorType.DIALOG,
//                           ),
//                           ignoreBlank: false,
//                           autoValidateMode: AutovalidateMode.disabled,
//                           selectorTextStyle:
//                               TextStyle(color: MyTheme.font_grey),
//                           // initialValue: phoneCode,
//                           textFieldController: _phoneNumberController,
//                           formatInput: true,
//                           keyboardType: TextInputType.numberWithOptions(
//                               signed: true, decimal: true),
//                           inputDecoration:
//                               InputDecorations.buildInputDecoration_phone(
//                                   hint_text: "01710 333 558"),
//                           onSaved: (PhoneNumber number) {
//                             //print('On Saved: $number');
//                           },
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _send_code_by = "email";
//                           });
//                         },
//                         child: Text(
//                           AppLocalizations.of(context)!.or_send_code_via_email,
//                           style: TextStyle(
//                               color: Colors.orange,
//                               fontStyle: FontStyle.italic,
//                               decoration: TextDecoration.underline),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 40.0),
//                 child: Container(
//                   height: 45,
//                   child: Btn.basic(
//                     minWidth: MediaQuery.of(context).size.width,
//                     // color: Colors.orange,
//                     color: Colors.black,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: const BorderRadius.all(
//                         Radius.circular(6.0),
//                       ),
//                     ),
//                     child: Text(
//                       "Send Code",
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600),
//                     ),
//                     onPressed: () {
//                       onPressSendCode();
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }

import 'package:ecom_flutter/custom/btn.dart';
import 'package:ecom_flutter/custom/input_decorations.dart';
import 'package:ecom_flutter/custom/intl_phone_input.dart';
import 'package:ecom_flutter/custom/toast_component.dart';
import 'package:ecom_flutter/helpers/shared_value_helper.dart';
import 'package:ecom_flutter/my_theme.dart';
import 'package:ecom_flutter/repositories/auth_repository.dart';
import 'package:ecom_flutter/screens/otp_test_screens/otp_screen.dart';
import 'package:ecom_flutter/screens/password_otp.dart';
import 'package:ecom_flutter/ui_elements/auth_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:toast/toast.dart';

import '../repositories/address_repository.dart';
import 'otp_test_screens/login_screen.dart';

class PasswordForget extends StatefulWidget {
  @override
  _PasswordForgetState createState() => _PasswordForgetState();
}

class _PasswordForgetState extends State<PasswordForget> {
  String _sendCodeBy = "email"; // phone or email
  String initialCountry = 'US';
  String? _phone = "";
  var countriesCode = <String?>[];

  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    fetchCountry();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressSendCode() async {
    var email = _emailController.text.toString();

    if (_sendCodeBy == 'email' && email == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_email,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (_sendCodeBy == 'phone' && _phone == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.enter_phone_number,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    var passwordForgetResponse = await AuthRepository()
        .getPasswordForgetResponse(
        _sendCodeBy == 'email' ? email : _phone, _sendCodeBy);

    if (passwordForgetResponse.result == false) {
      ToastComponent.showDialog(passwordForgetResponse.message!,
          gravity: Toast.center, duration: Toast.lengthLong);
    } else {
      ToastComponent.showDialog(passwordForgetResponse.message!,
          gravity: Toast.center, duration: Toast.lengthLong);

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PasswordOtp(
          // verify_by: _sendCodeBy,
          // phone_number: _phone,
          verify_by: _sendCodeBy,
          email: _sendCodeBy == 'email' ? email : null,
          phone_number: _sendCodeBy == 'phone' ? _phone : null,
        );
      }));
    }
  }

  fetchCountry() async {
    var data = await AddressRepository().getCountryList();
    data.countries.forEach((c) => countriesCode.add(c.code));
  }

  @override
  Widget build(BuildContext context) {
    final _screenWidth = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(
        context, "Forget Password!", buildBody(_screenWidth, context));
  }

  Column buildBody(double _screenWidth, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        Container(
          width: _screenWidth * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text("Email"),
                    selected: _sendCodeBy == "email",
                    onSelected: (isSelected) {
                      setState(() {
                        _sendCodeBy = "email";
                      });
                    },
                  ),
                  SizedBox(width: 10),
                  ChoiceChip(
                    label: Text("Phone"),
                    selected: _sendCodeBy == "phone",
                    onSelected: (isSelected) {
                      setState(() {
                        _sendCodeBy = "phone";
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              _sendCodeBy == "email"
                  ? buildEmailInput(context)
                  : buildPhoneInput(context),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Container(
                  height: 45,
                  child: Btn.basic(
                    minWidth: MediaQuery.of(context).size.width,
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(6.0),
                      ),
                    ),
                    child: Text(
                      // "Send Code",
                      "Confirmation",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: onPressSendCode,
                  ),
                ),
              ),
              // ElevatedButton(
              // onPressed: () {
              //   Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => OTPScreen(verificationId: "1"),
              //   ),);
              //   },
              //   child: Text('Go to Second Page'),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildEmailInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: _emailController,
        decoration: InputDecorations.buildInputDecoration_1(
          hint_text: "johndoe@example.com",
        ),
      ),
    );
  }

  Widget buildPhoneInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: CustomInternationalPhoneNumberInput(
        countries: countriesCode,
        onInputChanged: (PhoneNumber number) {
          setState(() {
            _phone = number.phoneNumber;
          });
        },
        selectorConfig: SelectorConfig(
          selectorType: PhoneInputSelectorType.DIALOG,
        ),
        textFieldController: _phoneNumberController,
        formatInput: true,
        keyboardType:
        TextInputType.numberWithOptions(signed: true, decimal: true),
        inputDecoration: InputDecorations.buildInputDecoration_phone(
            hint_text: "01710 333 558"),
      ),
    );
  }
}
