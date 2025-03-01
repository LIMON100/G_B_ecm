import 'dart:developer';
import 'dart:io';

import 'package:ecom_flutter/app_config.dart';
import 'package:ecom_flutter/custom/btn.dart';
import 'package:ecom_flutter/custom/device_info.dart';
import 'package:ecom_flutter/custom/google_recaptcha.dart';
import 'package:ecom_flutter/custom/input_decorations.dart';
import 'package:ecom_flutter/custom/intl_phone_input.dart';
import 'package:ecom_flutter/custom/toast_component.dart';
import 'package:ecom_flutter/data_model/login_response.dart';
import 'package:ecom_flutter/helpers/auth_helper.dart';
import 'package:ecom_flutter/helpers/shared_value_helper.dart';
import 'package:ecom_flutter/my_theme.dart';
import 'package:ecom_flutter/other_config.dart';
import 'package:ecom_flutter/repositories/auth_repository.dart';
import 'package:ecom_flutter/repositories/profile_repository.dart';
import 'package:ecom_flutter/screens/common_webview_screen.dart';
import 'package:ecom_flutter/screens/login.dart';
import 'package:ecom_flutter/screens/main.dart';
import 'package:ecom_flutter/ui_elements/auth_ui.dart';
import 'package:firebase_auth/firebase_auth.dart'  as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:toast/toast.dart';
import 'package:validators/validators.dart';
import 'package:ecom_flutter/screens/otp_test_screens/otp_screen.dart';

import '../custom/loading.dart';
import '../helpers/shared_value_helper.dart';
import '../helpers/system_config.dart';
import '../repositories/address_repository.dart';
import 'otp.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  String _register_by = "email"; //phone or email
  String initialCountry = 'US';

  // PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
  var countries_code = <String?>[];

  String? _phone = "";
  bool? _isAgree = false;
  bool _isCaptchaShowing = false;
  String googleRecaptchaKey = "";
  bool _isPhoneVerificationInProgress = false;

  //controllers
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    fetch_country();
  }

  fetch_country() async {
    var data = await AddressRepository().getCountryList();
    data.countries.forEach((c) => countries_code.add(c.code));
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressSignUp() async {
    if (_isPhoneVerificationInProgress) return;
    Loading.show(context);
    _isPhoneVerificationInProgress = true;

    var name = _nameController.text.toString();
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();
    var password_confirm = _passwordConfirmController.text.toString();

    if (name == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_your_name,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
    else if (_register_by == 'email' && (email == "" || !isEmail(email))) {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_email,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (_register_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.enter_phone_number,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }
    else if (password == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_password,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (password_confirm == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.confirm_your_password,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    } else if (password.length < 6) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!
              .password_must_contain_at_least_6_characters,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    } else if (password != password_confirm) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.passwords_do_not_match,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    if (_register_by == "phone") {
      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: _phone!,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _handleSuccessfulVerification(credential); // Handle auto-verification
          },
          verificationFailed: (FirebaseAuthException e) {
            _showError("Phone verification failed: ${e.message}");
          },
          codeSent: (String verificationId, int? resendToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  verificationId: verificationId,
                  phoneNumber: _phone!,
                  onVerificationSuccess: _handleSuccessfulVerification,
                  name: _nameController.text,
                  password: _passwordController.text,
                  passwordConfirm: _passwordConfirmController.text,
                  registerBy: _register_by,
                  googleRecaptchaKey: googleRecaptchaKey,
                ),
              ),
            );

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => OTPScreen(
            //       verificationId: verificationId,
            //       phoneNumber: _phone!,
            //       onVerificationSuccess: _handleSuccessfulVerification,
            //     ),
            //   ),
            // );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _showError("Verification timed out.");
          },
        );
      } catch (e) {
        _showError("An error occurred during phone verification.");
      }
    }
    else {
      try{
        var signupResponse = await AuthRepository().getSignupResponse(
            name,
            email,
            password,
            password_confirm,
            _register_by,
            googleRecaptchaKey);

        if (signupResponse.result == false) {
          //Error handling
          Loading.close();
          var message = "";
          signupResponse.message.forEach((value) {
            message += value + "\n";
          });
          ToastComponent.showDialog(message, gravity: Toast.center, duration: 3);
        } else {
          //Success
          Loading.close();
          ToastComponent.showDialog(signupResponse.message,
              gravity: Toast.center, duration: Toast.lengthLong);
          AuthHelper().setUserData(signupResponse);

          // redirect to main
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) => Main()), (newRoute) => false);
        }
      }catch (e){
        print("Exception: ${e.toString()}");
      }
    }
  }

  Future<void> _handleSuccessfulVerification(firebase_auth.PhoneAuthCredential credential) async {
    try {
      final firebase_auth.UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      // await _completeRegistration(userCredential.user!);
    } catch (e) {
      _showError("Firebase Sign-in Error: ${e.toString()}");
    } finally {
      setState(() {
        _isPhoneVerificationInProgress = false;
      });
      Loading.close();
    }
  }

  // Future<void> _completeRegistration(firebase_auth.User firebaseUser) async {
  //   try {
  //     var signupResponse = await AuthRepository().getSignupResponse(
  //       _nameController.text,
  //       _register_by == 'email' ? _emailController.text : _phone!,
  //       _passwordController.text,
  //       _passwordConfirmController.text,
  //       _register_by,
  //       googleRecaptchaKey,
  //       // firebaseUser.uid, // Pass the Firebase UID
  //     );
  //
  //     if (signupResponse.result == true) {
  //       // Update SystemConfig.systemUser with data from the signupResponse
  //       await AuthRepository().getMobileRConfirm();
  //       AuthHelper().setUserData(signupResponse);
  //       SystemConfig.systemUser!.phoneVerified = true; //Crucial update here
  //       ToastComponent.showDialog(signupResponse.message,
  //           gravity: Toast.center, duration: Toast.lengthLong);
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => Main()), (route) => false,
  //       );
  //     } else {
  //       _showError("Registration failed: ${signupResponse.message.join('\n')}");
  //       //Consider logging out of Firebase if registration failed.
  //     }
  //   } catch (e) {
  //     _showError("API Registration Error: ${e.toString()}"); //More specific error message
  //   }
  // }

  void _showError(String message) {
    setState(() {
      _isPhoneVerificationInProgress = false;
    });
    Loading.close();
    ToastComponent.showDialog(message, gravity: Toast.center, duration: Toast.lengthLong);
  }

  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(
        context,
        "${AppLocalizations.of(context)!.join_ucf} " + AppConfig.app_name,
        buildBody(context, _screen_width));
  }

  Column buildBody(BuildContext context, double _screen_width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _screen_width * (3 / 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  AppLocalizations.of(context)!.name_ucf,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  height: 36,
                  child: TextField(
                    controller: _nameController,
                    autofocus: false,
                    decoration: InputDecorations.buildInputDecoration_1(
                        hint_text: "John Doe"),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _register_by = "email";
                        });
                      },
                      child: Text(
                        'Register with Email',
                        style: TextStyle(
                          color: _register_by == 'email'
                              ? Colors.black // Highlight the active method
                              : MyTheme.font_grey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _register_by = "phone";
                        });
                      },
                      child: Text(
                        'Register with Phone',
                        style: TextStyle(
                          color: _register_by == 'phone'
                              ? Colors.black
                              : MyTheme.font_grey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_register_by == "email")
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 36,
                        child: TextField(
                          controller: _emailController,
                          autofocus: false,
                          decoration: InputDecorations.buildInputDecoration_1(
                              hint_text: "johndoe@example.com"),
                        ),
                      ),
                      otp_addon_installed.$
                          ? GestureDetector(
                        onTap: () {
                          setState(() {
                            _register_by = "phone";
                          });
                        },
                        child: Text(
                          AppLocalizations.of(context)!
                              .or_register_with_a_phone,
                          style: TextStyle(
                            // color: MyTheme.accent_color,
                              color: Colors.black,
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline),
                        ),
                      )
                          : Container()
                    ],
                  ),
                )
              // else
              else if (_register_by == "phone")
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 36,
                        child: CustomInternationalPhoneNumberInput(
                          countries: countries_code,
                          onInputChanged: (PhoneNumber number) {
                            print(number.phoneNumber);
                            setState(() {
                              _phone = number.phoneNumber;
                            });
                          },
                          onInputValidated: (bool value) {
                            print(value);
                          },
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.DIALOG,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle:
                          TextStyle(color: MyTheme.font_grey),
                          // initialValue: PhoneNumber(
                          //     isoCode: countries_code[0].toString()),
                          textFieldController: _phoneNumberController,
                          formatInput: true,
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          inputDecoration:
                          InputDecorations.buildInputDecoration_phone(
                              hint_text: "01XXX XXX XXX"),
                          onSaved: (PhoneNumber number) {
                            //print('On Saved: $number');
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _register_by = "email";
                          });
                        },
                        child: Text(
                          AppLocalizations.of(context)!
                              .or_register_with_an_email,
                          style: TextStyle(
                            // color: MyTheme.accent_color,
                              color: Colors.black,
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline),
                        ),
                      )
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  AppLocalizations.of(context)!.password_ucf,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 36,
                      child: TextField(
                        controller: _passwordController,
                        autofocus: false,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecorations.buildInputDecoration_1(
                            hint_text: "• • • • • • • •"),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!
                          .password_must_contain_at_least_6_characters,
                      style: TextStyle(
                          color: MyTheme.textfield_grey,
                          fontStyle: FontStyle.italic),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  AppLocalizations.of(context)!.retype_password_ucf,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  height: 36,
                  child: TextField(
                    controller: _passwordConfirmController,
                    autofocus: false,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecorations.buildInputDecoration_1(
                        hint_text: "• • • • • • • •"),
                  ),
                ),
              ),
              if (google_recaptcha.$)
                Container(
                  height: _isCaptchaShowing ? 350 : 50,
                  width: 300,
                  child: Captcha(
                        (keyValue) {
                      googleRecaptchaKey = keyValue;
                      setState(() {});
                    },
                    handleCaptcha: (data) {
                      if (_isCaptchaShowing.toString() != data) {
                        _isCaptchaShowing = data;
                        setState(() {});
                      }
                    },
                    isIOS: Platform.isIOS,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 15,
                      width: 15,
                      child: Checkbox(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          value: _isAgree,
                          onChanged: (newValue) {
                            _isAgree = newValue;
                            setState(() {});
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        width: DeviceInfo(context).width! - 130,
                        child: RichText(
                            maxLines: 2,
                            text: TextSpan(
                                style: TextStyle(
                                    color: MyTheme.font_grey, fontSize: 12),
                                children: [
                                  TextSpan(
                                    text: "I agree to the",
                                  ),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CommonWebviewScreen(
                                                      page_name:
                                                      "Terms Conditions",
                                                      url:
                                                      "${AppConfig.RAW_BASE_URL}/mobile-page/terms",
                                                    )));
                                      },
                                    style:
                                    TextStyle(color: Colors.black),
                                    text: " Terms Conditions",
                                  ),
                                  TextSpan(
                                    text: " &",
                                  ),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CommonWebviewScreen(
                                                      page_name:
                                                      "Privacy Policy",
                                                      url:
                                                      "${AppConfig.RAW_BASE_URL}/mobile-page/privacy-policy",
                                                    )));
                                      },
                                    text: " Privacy Policy",
                                    style:
                                    TextStyle(color: Colors.black),
                                  )
                                ])),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Container(
                  height: 45,
                  child: Btn.minWidthFixHeight(
                    minWidth: MediaQuery.of(context).size.width,
                    height: 50,
                    // color: MyTheme.accent_color,
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        const BorderRadius.all(Radius.circular(6.0))),
                    child: Text(
                      AppLocalizations.of(context)!.sign_up_ucf,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: _isAgree!
                        ? () {
                      onPressSignUp();
                    }
                        : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: Text(
                          AppLocalizations.of(context)!.already_have_an_account,
                          style: TextStyle(color: MyTheme.font_grey, fontSize: 12),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      child: Text(
                        AppLocalizations.of(context)!.log_in,
                        style: TextStyle(
                          // color: MyTheme.accent_color,
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return Login();
                            }));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}



//  EMAIL+PHONE NUmber field
// import 'dart:io';
//
// import 'package:ecom_flutter/app_config.dart';
// import 'package:ecom_flutter/custom/btn.dart';
// import 'package:ecom_flutter/custom/device_info.dart';
// import 'package:ecom_flutter/custom/google_recaptcha.dart';
// import 'package:ecom_flutter/custom/input_decorations.dart';
// import 'package:ecom_flutter/custom/intl_phone_input.dart';
// import 'package:ecom_flutter/custom/toast_component.dart';
// import 'package:ecom_flutter/data_model/login_response.dart';
// import 'package:ecom_flutter/helpers/auth_helper.dart';
// import 'package:ecom_flutter/helpers/shared_value_helper.dart';
// import 'package:ecom_flutter/my_theme.dart';
// import 'package:ecom_flutter/other_config.dart';
// import 'package:ecom_flutter/repositories/auth_repository.dart';
// import 'package:ecom_flutter/repositories/profile_repository.dart';
// import 'package:ecom_flutter/screens/common_webview_screen.dart';
// import 'package:ecom_flutter/screens/login.dart';
// import 'package:ecom_flutter/screens/main.dart';
// import 'package:ecom_flutter/ui_elements/auth_ui.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
// import 'package:toast/toast.dart';
// import 'package:validators/validators.dart';
//
// import '../custom/loading.dart';
// import '../helpers/shared_value_helper.dart';
// import '../repositories/address_repository.dart';
// import 'otp.dart';
//
// class Registration extends StatefulWidget {
//   @override
//   _RegistrationState createState() => _RegistrationState();
// }
//
// class _RegistrationState extends State<Registration> {
//   String _register_by = "email"; //phone or email
//   String initialCountry = 'US';
//
//   // PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
//   var countries_code = <String?>[];
//
//   String? _phone = "";
//   bool? _isAgree = false;
//   bool _isCaptchaShowing = false;
//   String googleRecaptchaKey = "";
//
//   //controllers
//   TextEditingController _nameController = TextEditingController();
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _phoneNumberController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();
//   TextEditingController _passwordConfirmController = TextEditingController();
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
//   fetch_country() async {
//     var data = await AddressRepository().getCountryList();
//     data.countries.forEach((c) => countries_code.add(c.code));
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
//   onPressSignUp() async {
//     Loading.show(context);
//
//     var name = _nameController.text.toString();
//     var email = _emailController.text.toString();
//     var password = _passwordController.text.toString();
//     var password_confirm = _passwordConfirmController.text.toString();
//
//     if (name == "") {
//       ToastComponent.showDialog(AppLocalizations.of(context)!.enter_your_name,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       return;
//     }
//     else if (_register_by == 'email' && (email == "" || !isEmail(email))) {
//       print("RESGITER_EMAIL");
//       ToastComponent.showDialog(AppLocalizations.of(context)!.enter_email,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       return;
//     } else if (_register_by == 'phone' && _phone == "") {
//       print("RESGITER_PHONE");
//       ToastComponent.showDialog(
//           AppLocalizations.of(context)!.enter_phone_number,
//           gravity: Toast.center,
//           duration: Toast.lengthLong);
//       return;
//     }
//     else if (password == "") {
//       ToastComponent.showDialog(AppLocalizations.of(context)!.enter_password,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       return;
//     } else if (password_confirm == "") {
//       ToastComponent.showDialog(
//           AppLocalizations.of(context)!.confirm_your_password,
//           gravity: Toast.center,
//           duration: Toast.lengthLong);
//       return;
//     } else if (password.length < 6) {
//       ToastComponent.showDialog(
//           AppLocalizations.of(context)!
//               .password_must_contain_at_least_6_characters,
//           gravity: Toast.center,
//           duration: Toast.lengthLong);
//       return;
//     } else if (password != password_confirm) {
//       ToastComponent.showDialog(
//           AppLocalizations.of(context)!.passwords_do_not_match,
//           gravity: Toast.center,
//           duration: Toast.lengthLong);
//       return;
//     }
//
//     var signupResponse = await AuthRepository().getSignupResponse(
//         name,
//         _register_by == 'email' ? email : _phone,
//         password,
//         password_confirm,
//         _register_by,
//         googleRecaptchaKey
//     );
//     print('Signup Response:');
//     print(signupResponse.result);
//     Loading.close();
//
//
//     if (signupResponse.result == false) {
//       var message = "";
//       signupResponse.message.forEach((value) {
//         message += value + "\n";
//       });
//       ToastComponent.showDialog(message, gravity: Toast.center, duration: 3);
//     } else {
//       // Skip the ToastComponent it works
//       ToastComponent.showDialog(signupResponse.message,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       AuthHelper().setUserData(signupResponse);
//
//       // redirect to main
//       Navigator.pushAndRemoveUntil(context,
//           MaterialPageRoute(builder: (context) {
//             return Main();
//           }), (newRoute) => false);
//
//       // push notification starts
//       if (OtherConfig.USE_PUSH_NOTIFICATION) {
//         final FirebaseMessaging _fcm = FirebaseMessaging.instance;
//         await _fcm.requestPermission(
//           alert: true,
//           announcement: false,
//           badge: true,
//           carPlay: false,
//           criticalAlert: false,
//           provisional: false,
//           sound: true,
//         );
//
//         String? fcmToken = await _fcm.getToken();
//
//         if (fcmToken != null) {
//           print("--fcm token--");
//           print(fcmToken);
//           if (is_logged_in.$ == true) {
//             // update device token
//             var deviceTokenUpdateResponse = await ProfileRepository()
//                 .getDeviceTokenUpdateResponse(fcmToken);
//           }
//         }
//       }
//
//
//       // if ((mail_verification_status.$ && _register_by == "email") ||
//       //     _register_by == "phone") {
//       //   Navigator.push(context, MaterialPageRoute(builder: (context) {
//       //     return Otp(
//       //       verify_by: _register_by,
//       //       user_id: signupResponse.user_id,
//       //     );
//       //   }));
//       // } else {
//       //   Navigator.push(context, MaterialPageRoute(builder: (context) {
//       //     return Login();
//       //   }));
//       // }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final _screen_height = MediaQuery.of(context).size.height;
//     final _screen_width = MediaQuery.of(context).size.width;
//     return AuthScreen.buildScreen(
//         context,
//         "${AppLocalizations.of(context)!.join_ucf} " + AppConfig.app_name,
//         buildBody(context, _screen_width));
//   }
//
//   Column buildBody(BuildContext context, double _screen_width) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Container(
//           width: _screen_width * (3 / 4),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 4.0),
//                 child: Text(
//                   AppLocalizations.of(context)!.name_ucf,
//                   style: TextStyle(
//                       color: Colors.black, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: Container(
//                   height: 36,
//                   child: TextField(
//                     controller: _nameController,
//                     autofocus: false,
//                     decoration: InputDecorations.buildInputDecoration_1(
//                         hint_text: "John Doe"),
//                   ),
//                 ),
//               ),
//               // Padding(
//               //   padding: const EdgeInsets.only(bottom: 4.0),
//               //   child: Text(
//               //     _register_by == "email"
//               //         ? AppLocalizations.of(context)!.email_ucf
//               //         : AppLocalizations.of(context)!.phone_ucf,
//               //     style: TextStyle(
//               //         color: Colors.black, fontWeight: FontWeight.w600),
//               //   ),
//               // ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _register_by = "email";
//                         });
//                       },
//                       child: Text(
//                         'Register with Email',
//                         style: TextStyle(
//                           color: _register_by == 'email'
//                               ? Colors.black // Highlight the active method
//                               : MyTheme.font_grey,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 20),
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _register_by = "phone";
//                         });
//                       },
//                       child: Text(
//                         'Register with Phone',
//                         style: TextStyle(
//                           color: _register_by == 'phone'
//                               ? Colors.black
//                               : MyTheme.font_grey,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (_register_by == "email")
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
//                                   _register_by = "phone";
//                                 });
//                               },
//                               child: Text(
//                                 AppLocalizations.of(context)!
//                                     .or_register_with_a_phone,
//                                 style: TextStyle(
//                                     // color: MyTheme.accent_color,
//                                     color: Colors.black,
//                                     fontStyle: FontStyle.italic,
//                                     decoration: TextDecoration.underline),
//                               ),
//                             )
//                           : Container()
//                     ],
//                   ),
//                 )
//               // else
//               else if (_register_by == "phone")
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
//                             print(number.phoneNumber);
//                             setState(() {
//                               _phone = number.phoneNumber;
//                             });
//                           },
//                           onInputValidated: (bool value) {
//                             print(value);
//                           },
//                           selectorConfig: SelectorConfig(
//                             selectorType: PhoneInputSelectorType.DIALOG,
//                           ),
//                           ignoreBlank: false,
//                           autoValidateMode: AutovalidateMode.disabled,
//                           selectorTextStyle:
//                               TextStyle(color: MyTheme.font_grey),
//                           // initialValue: PhoneNumber(
//                           //     isoCode: countries_code[0].toString()),
//                           textFieldController: _phoneNumberController,
//                           formatInput: true,
//                           keyboardType: TextInputType.numberWithOptions(
//                               signed: true, decimal: true),
//                           inputDecoration:
//                               InputDecorations.buildInputDecoration_phone(
//                                   hint_text: "01XXX XXX XXX"),
//                           onSaved: (PhoneNumber number) {
//                             //print('On Saved: $number');
//                           },
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _register_by = "email";
//                           });
//                         },
//                         child: Text(
//                           AppLocalizations.of(context)!
//                               .or_register_with_an_email,
//                           style: TextStyle(
//                               // color: MyTheme.accent_color,
//                               color: Colors.black,
//                               fontStyle: FontStyle.italic,
//                               decoration: TextDecoration.underline),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 4.0),
//                 child: Text(
//                   AppLocalizations.of(context)!.password_ucf,
//                   style: TextStyle(
//                       color: Colors.black, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Container(
//                       height: 36,
//                       child: TextField(
//                         controller: _passwordController,
//                         autofocus: false,
//                         obscureText: true,
//                         enableSuggestions: false,
//                         autocorrect: false,
//                         decoration: InputDecorations.buildInputDecoration_1(
//                             hint_text: "• • • • • • • •"),
//                       ),
//                     ),
//                     Text(
//                       AppLocalizations.of(context)!
//                           .password_must_contain_at_least_6_characters,
//                       style: TextStyle(
//                           color: MyTheme.textfield_grey,
//                           fontStyle: FontStyle.italic),
//                     )
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 4.0),
//                 child: Text(
//                   AppLocalizations.of(context)!.retype_password_ucf,
//                   style: TextStyle(
//                       color: Colors.black, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: Container(
//                   height: 36,
//                   child: TextField(
//                     controller: _passwordConfirmController,
//                     autofocus: false,
//                     obscureText: true,
//                     enableSuggestions: false,
//                     autocorrect: false,
//                     decoration: InputDecorations.buildInputDecoration_1(
//                         hint_text: "• • • • • • • •"),
//                   ),
//                 ),
//               ),
//               if (google_recaptcha.$)
//                 Container(
//                   height: _isCaptchaShowing ? 350 : 50,
//                   width: 300,
//                   child: Captcha(
//                     (keyValue) {
//                       googleRecaptchaKey = keyValue;
//                       setState(() {});
//                     },
//                     handleCaptcha: (data) {
//                       if (_isCaptchaShowing.toString() != data) {
//                         _isCaptchaShowing = data;
//                         setState(() {});
//                       }
//                     },
//                     isIOS: Platform.isIOS,
//                   ),
//                 ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 20.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       height: 15,
//                       width: 15,
//                       child: Checkbox(
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(6)),
//                           value: _isAgree,
//                           onChanged: (newValue) {
//                             _isAgree = newValue;
//                             setState(() {});
//                           }),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 8.0),
//                       child: Container(
//                         width: DeviceInfo(context).width! - 130,
//                         child: RichText(
//                             maxLines: 2,
//                             text: TextSpan(
//                                 style: TextStyle(
//                                     color: MyTheme.font_grey, fontSize: 12),
//                                 children: [
//                                   TextSpan(
//                                     text: "I agree to the",
//                                   ),
//                                   TextSpan(
//                                     recognizer: TapGestureRecognizer()
//                                       ..onTap = () {
//                                         Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     CommonWebviewScreen(
//                                                       page_name:
//                                                           "Terms Conditions",
//                                                       url:
//                                                           "${AppConfig.RAW_BASE_URL}/mobile-page/terms",
//                                                     )));
//                                       },
//                                     style:
//                                         TextStyle(color: Colors.black),
//                                     text: " Terms Conditions",
//                                   ),
//                                   TextSpan(
//                                     text: " &",
//                                   ),
//                                   TextSpan(
//                                     recognizer: TapGestureRecognizer()
//                                       ..onTap = () {
//                                         Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     CommonWebviewScreen(
//                                                       page_name:
//                                                           "Privacy Policy",
//                                                       url:
//                                                           "${AppConfig.RAW_BASE_URL}/mobile-page/privacy-policy",
//                                                     )));
//                                       },
//                                     text: " Privacy Policy",
//                                     style:
//                                         TextStyle(color: Colors.black),
//                                   )
//                                 ])),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 30.0),
//                 child: Container(
//                   height: 45,
//                   child: Btn.minWidthFixHeight(
//                     minWidth: MediaQuery.of(context).size.width,
//                     height: 50,
//                     // color: MyTheme.accent_color,
//                     color: Colors.black,
//                     shape: RoundedRectangleBorder(
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(6.0))),
//                     child: Text(
//                       AppLocalizations.of(context)!.sign_up_ucf,
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600),
//                     ),
//                     onPressed: _isAgree!
//                         ? () {
//                             onPressSignUp();
//                           }
//                         : null,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 20.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Center(
//                         child: Text(
//                       AppLocalizations.of(context)!.already_have_an_account,
//                       style: TextStyle(color: MyTheme.font_grey, fontSize: 12),
//                     )),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     InkWell(
//                       child: Text(
//                         AppLocalizations.of(context)!.log_in,
//                         style: TextStyle(
//                             // color: MyTheme.accent_color,
//                             color: Colors.black,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600),
//                       ),
//                       onTap: () {
//                         Navigator.push(context,
//                             MaterialPageRoute(builder: (context) {
//                           return Login();
//                         }));
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }


// ONLY ONE EMAIL FIELD
// import 'dart:io';
//
// import 'package:ecom_flutter/app_config.dart';
// import 'package:ecom_flutter/custom/btn.dart';
// import 'package:ecom_flutter/custom/device_info.dart';
// import 'package:ecom_flutter/custom/google_recaptcha.dart';
// import 'package:ecom_flutter/custom/input_decorations.dart';
// import 'package:ecom_flutter/custom/intl_phone_input.dart';
// import 'package:ecom_flutter/custom/toast_component.dart';
// import 'package:ecom_flutter/data_model/login_response.dart';
// import 'package:ecom_flutter/helpers/auth_helper.dart';
// import 'package:ecom_flutter/helpers/shared_value_helper.dart';
// import 'package:ecom_flutter/my_theme.dart';
// import 'package:ecom_flutter/other_config.dart';
// import 'package:ecom_flutter/repositories/auth_repository.dart';
// import 'package:ecom_flutter/repositories/profile_repository.dart';
// import 'package:ecom_flutter/screens/common_webview_screen.dart';
// import 'package:ecom_flutter/screens/login.dart';
// import 'package:ecom_flutter/screens/main.dart';
// import 'package:ecom_flutter/ui_elements/auth_ui.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
// import 'package:toast/toast.dart';
// import 'package:validators/validators.dart';
//
// import '../custom/loading.dart';
// import '../helpers/shared_value_helper.dart';
// import '../repositories/address_repository.dart';
// import 'otp.dart';
//
// class Registration extends StatefulWidget {
//   @override
//   _RegistrationState createState() => _RegistrationState();
// }
//
// class _RegistrationState extends State<Registration> {
//   // String _register_by = "email"; //phone or email
//   // var countries_code = <String?>[];
//
//   String? _emailOrPhone = "";
//   bool? _isAgree = false;
//   bool _isCaptchaShowing = false;
//   String googleRecaptchaKey = "";
//
//   //controllers
//   TextEditingController _nameController = TextEditingController();
//   TextEditingController _emailOrPhoneController = TextEditingController();
//   // TextEditingController _phoneNumberController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();
//   TextEditingController _passwordConfirmController = TextEditingController();
//
//   @override
//   void initState() {
//     //on Splash Screen hide statusbar
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: [SystemUiOverlay.bottom]);
//     super.initState();
//     // fetch_country();
//   }
//
//   // fetch_country() async {
//   //   var data = await AddressRepository().getCountryList();
//   //   data.countries.forEach((c) => countries_code.add(c.code));
//   // }
//
//   @override
//   void dispose() {
//     //before going to other screen show statusbar
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
//     super.dispose();
//   }
//
//   onPressSignUp() async {
//     Loading.show(context);
//
//     var name = _nameController.text.toString();
//     var emailOrPhone = _emailOrPhoneController.text.toString();
//     var password = _passwordController.text.toString();
//     var password_confirm = _passwordConfirmController.text.toString();
//
//     if (name == "") {
//       ToastComponent.showDialog(AppLocalizations.of(context)!.enter_your_name,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       return;
//     }
//     else if (emailOrPhone == "") {
//       ToastComponent.showDialog(AppLocalizations.of(context)!.enter_email,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       return;
//     }
//     else if (password == "") {
//       ToastComponent.showDialog(AppLocalizations.of(context)!.enter_password,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       return;
//     } else if (password_confirm == "") {
//       ToastComponent.showDialog(
//           AppLocalizations.of(context)!.confirm_your_password,
//           gravity: Toast.center,
//           duration: Toast.lengthLong);
//       return;
//     } else if (password.length < 6) {
//       ToastComponent.showDialog(
//           AppLocalizations.of(context)!
//               .password_must_contain_at_least_6_characters,
//           gravity: Toast.center,
//           duration: Toast.lengthLong);
//       return;
//     } else if (password != password_confirm) {
//       ToastComponent.showDialog(
//           AppLocalizations.of(context)!.passwords_do_not_match,
//           gravity: Toast.center,
//           duration: Toast.lengthLong);
//       return;
//     }
//
//     var signupResponse = await AuthRepository().getSignupResponse(
//         name,
//         emailOrPhone,
//         password,
//         password_confirm,
//         "email", // Assuming always email for simplicity
//         googleRecaptchaKey
//     );
//     print('Signup Response:');
//     print(signupResponse.result);
//     Loading.close();
//
//
//     if (signupResponse.result == false) {
//       var message = "";
//       signupResponse.message.forEach((value) {
//         message += value + "\n";
//       });
//       ToastComponent.showDialog(message, gravity: Toast.center, duration: 3);
//     } else {
//       // Skip the ToastComponent it works
//       ToastComponent.showDialog(signupResponse.message,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       AuthHelper().setUserData(signupResponse);
//
//       // redirect to main
//       Navigator.pushAndRemoveUntil(context,
//           MaterialPageRoute(builder: (context) {
//             return Main();
//           }), (newRoute) => false);
//
//       // push notification starts
//       if (OtherConfig.USE_PUSH_NOTIFICATION) {
//         final FirebaseMessaging _fcm = FirebaseMessaging.instance;
//         await _fcm.requestPermission(
//           alert: true,
//           announcement: false,
//           badge: true,
//           carPlay: false,
//           criticalAlert: false,
//           provisional: false,
//           sound: true,
//         );
//
//         String? fcmToken = await _fcm.getToken();
//
//         if (fcmToken != null) {
//           print("--fcm token--");
//           print(fcmToken);
//           if (is_logged_in.$ == true) {
//             // update device token
//             var deviceTokenUpdateResponse = await ProfileRepository()
//                 .getDeviceTokenUpdateResponse(fcmToken);
//           }
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final _screen_height = MediaQuery.of(context).size.height;
//     final _screen_width = MediaQuery.of(context).size.width;
//     return AuthScreen.buildScreen(
//         context,
//         "${AppLocalizations.of(context)!.join_ucf} " + AppConfig.app_name,
//         buildBody(context, _screen_width));
//   }
//
//   Column buildBody(BuildContext context, double _screen_width) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Container(
//           width: _screen_width * (3 / 4),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 4.0),
//                 child: Text(
//                   AppLocalizations.of(context)!.name_ucf,
//                   style: TextStyle(
//                       color: Colors.black, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: Container(
//                   height: 36,
//                   child: TextField(
//                     controller: _nameController,
//                     autofocus: false,
//                     decoration: InputDecorations.buildInputDecoration_1(
//                         hint_text: "John Doe"),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 4.0),
//                 child: Text(
//                   AppLocalizations.of(context)!.email_ucf,
//                   style: TextStyle(
//                       color: Colors.black, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: Container(
//                   height: 36,
//                   child: TextField(
//                     controller: _emailOrPhoneController,
//                     autofocus: false,
//                     decoration: InputDecorations.buildInputDecoration_1(
//                         hint_text: "Enter Email or Phone"),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 4.0),
//                 child: Text(
//                   AppLocalizations.of(context)!.password_ucf,
//                   style: TextStyle(
//                       color: Colors.black, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Container(
//                       height: 36,
//                       child: TextField(
//                         controller: _passwordController,
//                         autofocus: false,
//                         obscureText: true,
//                         enableSuggestions: false,
//                         autocorrect: false,
//                         decoration: InputDecorations.buildInputDecoration_1(
//                             hint_text: "• • • • • • • •"),
//                       ),
//                     ),
//                     Text(
//                       AppLocalizations.of(context)!
//                           .password_must_contain_at_least_6_characters,
//                       style: TextStyle(
//                           color: MyTheme.textfield_grey,
//                           fontStyle: FontStyle.italic),
//                     )
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 4.0),
//                 child: Text(
//                   AppLocalizations.of(context)!.retype_password_ucf,
//                   style: TextStyle(
//                       color: Colors.black, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: Container(
//                   height: 36,
//                   child: TextField(
//                     controller: _passwordConfirmController,
//                     autofocus: false,
//                     obscureText: true,
//                     enableSuggestions: false,
//                     autocorrect: false,
//                     decoration: InputDecorations.buildInputDecoration_1(
//                         hint_text: "• • • • • • • •"),
//                   ),
//                 ),
//               ),
//               if (google_recaptcha.$)
//                 Container(
//                   height: _isCaptchaShowing ? 350 : 50,
//                   width: 300,
//                   child: Captcha(
//                         (keyValue) {
//                       googleRecaptchaKey = keyValue;
//                       setState(() {});
//                     },
//                     handleCaptcha: (data) {
//                       if (_isCaptchaShowing.toString() != data) {
//                         _isCaptchaShowing = data;
//                         setState(() {});
//                       }
//                     },
//                     isIOS: Platform.isIOS,
//                   ),
//                 ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 20.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       height: 15,
//                       width: 15,
//                       child: Checkbox(
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(6)),
//                           value: _isAgree,
//                           onChanged: (newValue) {
//                             _isAgree = newValue;
//                             setState(() {});
//                           }),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 8.0),
//                       child: Container(
//                         width: DeviceInfo(context).width! - 130,
//                         child: RichText(
//                             maxLines: 2,
//                             text: TextSpan(
//                                 style: TextStyle(
//                                     color: MyTheme.font_grey, fontSize: 12),
//                                 children: [
//                                   TextSpan(
//                                     text: "I agree to the",
//                                   ),
//                                   TextSpan(
//                                     recognizer: TapGestureRecognizer()
//                                       ..onTap = () {
//                                         Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     CommonWebviewScreen(
//                                                       page_name:
//                                                       "Terms Conditions",
//                                                       url:
//                                                       "${AppConfig.RAW_BASE_URL}/mobile-page/terms",
//                                                     )));
//                                       },
//                                     style:
//                                     TextStyle(color: Colors.black),
//                                     text: " Terms Conditions",
//                                   ),
//                                   TextSpan(
//                                     text: " &",
//                                   ),
//                                   TextSpan(
//                                     recognizer: TapGestureRecognizer()
//                                       ..onTap = () {
//                                         Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     CommonWebviewScreen(
//                                                       page_name:
//                                                       "Privacy Policy",
//                                                       url:
//                                                       "${AppConfig.RAW_BASE_URL}/mobile-page/privacy-policy",
//                                                     )));
//                                       },
//                                     text: " Privacy Policy",
//                                     style:
//                                     TextStyle(color: Colors.black),
//                                   )
//                                 ])),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 30.0),
//                 child: Container(
//                   height: 45,
//                   child: Btn.minWidthFixHeight(
//                     minWidth: MediaQuery.of(context).size.width,
//                     height: 50,
//                     // color: MyTheme.accent_color,
//                     color: Colors.black,
//                     shape: RoundedRectangleBorder(
//                         borderRadius:
//                         const BorderRadius.all(Radius.circular(6.0))),
//                     child: Text(
//                       AppLocalizations.of(context)!.sign_up_ucf,
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600),
//                     ),
//                     onPressed: _isAgree!
//                         ? () {
//                       onPressSignUp();
//                     }
//                         : null,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 20.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Center(
//                         child: Text(
//                           AppLocalizations.of(context)!.already_have_an_account,
//                           style: TextStyle(color: MyTheme.font_grey, fontSize: 12),
//                         )),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     InkWell(
//                       child: Text(
//                         AppLocalizations.of(context)!.log_in,
//                         style: TextStyle(
//                           // color: MyTheme.accent_color,
//                             color: Colors.black,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600),
//                       ),
//                       onTap: () {
//                         Navigator.push(context,
//                             MaterialPageRoute(builder: (context) {
//                               return Login();
//                             }));
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }