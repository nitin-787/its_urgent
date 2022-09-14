import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../settings/index.dart';
import '../../provider/login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  bool otpVisibility = false;
  User? user;
  String verificationID = "";

  bool allDetailesFilled() {
    return phoneController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneController.text.length == 10;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginProvider(),
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Image.asset("assets/images/hey.png"),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Name',
                labelText: 'Enter the name',
                border: OutlineInputBorder(),
                prefix: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Text(''),
                ),
              ),
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: 2.5.h),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
                labelText: 'Enter the email',
                border: OutlineInputBorder(),
                prefix: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Text(''),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 2.5.h),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                hintText: 'Phone Number',
                labelText: 'Enter the phone number',
                border: const OutlineInputBorder(),
                prefix: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.sp),
                  child: const Text('+91'),
                ),
              ),
              maxLength: 10,
              keyboardType: TextInputType.phone,
            ),
            Visibility(
              visible: otpVisibility,
              child: TextField(
                controller: otpController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter the OTP',
                  prefix: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(''),
                  ),
                ),
                maxLength: 6,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 5.sp),
            ElevatedButton(
              onPressed: () {
                if (otpVisibility) {
                  verifyOTP();
                } else {
                  loginWithPhone();
                }
              },
              child: Text(
                otpVisibility ? "Verify" : "Login",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(height: 5.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // primery is deprecated in v3.3.0
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    final provider =
                        Provider.of<LoginProvider>(context, listen: false);
                    provider.googleLogin();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: const AssetImage("assets/icons/g-logo.png"),
                          height: 4.h,
                          width: 6.7.w,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 4.sp, right: 4.sp),
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void loginWithPhone() async {
    if (allDetailesFilled()) {
      auth.verifyPhoneNumber(
        phoneNumber: "+91${phoneController.text}",
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential).then((value) {
            //print("You are logged in successfully");
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          //print(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          otpVisibility = true;
          verificationID = verificationId;
          setState(() {});
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } else {
      Fluttertoast.showToast(
        msg: "Please fill all the details",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 10.sp,
      );
    }
  }

  void verifyOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: otpController.text);

    await auth.signInWithCredential(credential).then(
      (value) {
        setState(() {
          user = FirebaseAuth.instance.currentUser;
        });
      },
    ).whenComplete(
      () {
        if (user != null) {
          final provider = Provider.of<LoginProvider>(context, listen: false);
          provider.phoneLogin(
              nameController.text, emailController.text, phoneController.text);

          Fluttertoast.showToast(
            msg: "You are logged in successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 10.sp,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingPage(),
            ),
          );
        } else {
          Fluttertoast.showToast(
            msg: "Wrong OTP",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 10.sp,
          );
        }
      },
    );
  }
}
