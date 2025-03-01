// import 'dart:developer';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:ecom_flutter/screens/otp_test_screens/home_screen.dart';
//
// import '../../custom/btn.dart';
// import '../../my_theme.dart';
//
// class OTPScreen extends StatefulWidget {
//   const OTPScreen({super.key, required this.verificationId});
//   final String verificationId;
//
//   @override
//   State<OTPScreen> createState() => _OTPScreenState();
// }
//
// class _OTPScreenState extends State<OTPScreen> {
//   final otpController = TextEditingController();
//
//   bool isLoading = false;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 30),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 5.0),
//             child: Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8,vertical: 12),
//                   width: 200,
//                   height: 200,
//                   decoration: BoxDecoration(
//                       color: MyTheme.white,
//                       borderRadius: BorderRadius.circular(8)),
//                   child: Image.asset('assets/login_registration_form_logo.png'),
//                 ),
//               ],
//               mainAxisAlignment: MainAxisAlignment.center,
//             ),
//           ),
//           const Text(
//             "We have sent an OTP to your phone. Please verify",
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 18),
//           ),
//           const SizedBox(height: 10),
//           TextField(
//             controller: otpController,
//             keyboardType: TextInputType.phone,
//             decoration: InputDecoration(
//                 fillColor: Colors.grey.withOpacity(0.25),
//                 filled: true,
//                 hintText: "Enter OTP",
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide.none)),
//           ),
//           const SizedBox(height: 20),
//           isLoading
//               ? const CircularProgressIndicator()
//           //     : ElevatedButton(
//           //         onPressed: () async {
//           //           setState(() {
//           //             isLoading = true;
//           //           });
//           //
//           //           try {
//           //             final cred = PhoneAuthProvider.credential(
//           //                 verificationId: widget.verificationId,
//           //                 smsCode: otpController.text);
//           //
//           //             await FirebaseAuth.instance.signInWithCredential(cred);
//           //
//           //             Navigator.push(
//           //                 context,
//           //                 MaterialPageRoute(
//           //                   builder: (context) => const HomeScreen(),
//           //                 ));
//           //           } catch (e) {
//           //             log(e.toString());
//           //           }
//           //           setState(() {
//           //             isLoading = false;
//           //           });
//           //         },
//           //         child: const Text(
//           //           "Verify",
//           //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
//           //         ),
//           // ),
//               :Container(
//                 height: 45,
//                 child: Btn.minWidthFixHeight(
//                   minWidth: MediaQuery.of(context).size.width,
//                   height: 50,
//                   color: MyTheme.amber,
//                   shape: RoundedRectangleBorder(
//                       borderRadius:
//                       const BorderRadius.all(Radius.circular(6.0))),
//                   child: Text(
//                     "Verify",
//                     style: TextStyle(
//                       // color: MyTheme.accent_color,
//                         color: Colors.black,
//                         fontSize: 22,
//                         fontWeight: FontWeight.w600),
//                   ),
//                   onPressed: () async {
//                     setState(() {
//                       isLoading = true;
//                     });
//
//                     try {
//                       final cred = PhoneAuthProvider.credential(
//                           verificationId: widget.verificationId,
//                           smsCode: otpController.text);
//
//                       await FirebaseAuth.instance.signInWithCredential(cred);
//
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const HomeScreen(),
//                           ));
//                     } catch (e) {
//                       log(e.toString());
//                     }
//                     setState(() {
//                       isLoading = false;
//                     });
//                   },
//                 ),
//               ),
//         ],
//       ),
//     ));
//   }
// }


import 'dart:developer';
import 'package:ecom_flutter/screens/registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import '../../custom/btn.dart';
import '../../custom/toast_component.dart';
import '../../helpers/auth_helper.dart';
import '../../helpers/system_config.dart';
import '../../my_theme.dart';
import '../../repositories/auth_repository.dart';
import '../main.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'  as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ecom_flutter/screens/registration.dart' as rg;

// class OTPScreen extends StatefulWidget {
//   const OTPScreen({
//     super.key,
//     required this.verificationId,
//     required this.phoneNumber,
//     required this.onVerificationSuccess,
//   });
//
//   final String verificationId;
//   final String phoneNumber;
//   final void Function(PhoneAuthCredential) onVerificationSuccess; //void is correct
//
//   @override
//   State<OTPScreen> createState() => _OTPScreenState();
// }
//
// class _OTPScreenState extends State<OTPScreen> {
//   final otpController = TextEditingController();
//   bool isLoading = false;
//
//   @override
//   void dispose() {
//     otpController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: const Text("OTP Verification")),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 30),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 5.0),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 8,vertical: 12),
//                     width: 200,
//                     height: 200,
//                     decoration: BoxDecoration(
//                         color: MyTheme.white,
//                         borderRadius: BorderRadius.circular(8)),
//                     child: Image.asset('assets/login_registration_form_logo.png'),
//                   ),
//                 ],
//                 mainAxisAlignment: MainAxisAlignment.center,
//               ),
//             ),
//             Text(
//               "We have sent an OTP to +${widget.phoneNumber}. Please verify.",
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: otpController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 fillColor: Colors.grey,
//                 filled: true,
//                 hintText: "Enter OTP",
//                 border: OutlineInputBorder(
//                   // borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             isLoading
//                 ? const CircularProgressIndicator()
//                 :Container(
//               height: 45,
//               child: Btn.minWidthFixHeight(
//                 minWidth: MediaQuery.of(context).size.width,
//                 height: 50,
//                 color: MyTheme.amber,
//                 shape: RoundedRectangleBorder(
//                     borderRadius:
//                     const BorderRadius.all(Radius.circular(6.0))),
//                 child: Text(
//                   "Verify",
//                   style: TextStyle(
//                     // color: MyTheme.accent_color,
//                       color: Colors.black,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w600),
//                 ),
//                 onPressed: () async {
//                   setState(() {
//                     isLoading = true;
//                   });
//                   try {
//                     final cred = PhoneAuthProvider.credential(
//                         verificationId: widget.verificationId,
//                         smsCode: otpController.text);
//
//                     await FirebaseAuth.instance.signInWithCredential(cred);
//
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => Registration(),
//                         ));
//                   } catch (e) {
//                     log(e.toString());
//                   }
//                   setState(() {
//                     isLoading = false;
//                   });
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class OTPScreen extends StatefulWidget {
  const OTPScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.onVerificationSuccess,
    required this.name,
    required this.password,
    required this.passwordConfirm,
    required this.registerBy,
    required this.googleRecaptchaKey,
  });

  final String verificationId;
  final String phoneNumber;
  final void Function(PhoneAuthCredential) onVerificationSuccess;
  final String name;
  final String password;
  final String passwordConfirm;
  final String registerBy;
  final String googleRecaptchaKey;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final otpController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> _completeRegistration() async {
    try {
      setState(() {
        isLoading = true;
      });

      var signupResponse = await AuthRepository().getSignupResponse(
        widget.name,
        widget.registerBy == 'email' ? widget.phoneNumber : widget.phoneNumber,
        widget.password,
        widget.passwordConfirm,
        widget.registerBy,
        widget.googleRecaptchaKey,
      );

      if (signupResponse.result == true) {
        // await AuthRepository().getMobileRConfirm();
        AuthHelper().setUserData(signupResponse);
        await AuthRepository().getMobileRConfirm(signupResponse.access_token);
        ToastComponent.showDialog(signupResponse.message,
            gravity: Toast.center, duration: Toast.lengthLong);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Main()),
              (route) => false,
        );
      } else {
        _showError("Registration failed: ${signupResponse.message.join('\n')}");
      }
    } catch (e) {
      _showError("API Registration Error: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ToastComponent.showDialog(message,
        gravity: Toast.center, duration: Toast.lengthLong);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align children at the top
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50), // Add space at the top
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: MyTheme.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset('assets/login_registration_form_logo.png'),
            ),
            const SizedBox(height: 30), // Add space between the image and text
            Text(
              "We have sent an OTP to +${widget.phoneNumber}. Please verify.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                fillColor: Colors.grey,
                filled: true,
                hintText: "Enter OTP",
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              height: 45,
              child: Btn.minWidthFixHeight(
                minWidth: MediaQuery.of(context).size.width,
                height: 50,
                color: MyTheme.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                ),
                child: Text(
                  "Verify",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  try {
                    final cred = PhoneAuthProvider.credential(
                      verificationId: widget.verificationId,
                      smsCode: otpController.text,
                    );

                    await FirebaseAuth.instance.signInWithCredential(cred);

                    // Complete Registration after successful OTP verification
                    await _completeRegistration();
                  } catch (e) {
                    _showError("Invalid OTP. Please try again.");
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );

  }
}
