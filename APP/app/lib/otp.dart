import 'dart:ffi';

import 'package:app/password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:google_fonts/google_fonts.dart';

class OTPscreen extends StatefulWidget {
  final String phone;
  OTPscreen(this.phone);

  @override
  _OTPscreenState createState() => _OTPscreenState();
}

class _OTPscreenState extends State<OTPscreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  late String _verificationCode;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final BoxDecoration _pinPutDecoration = BoxDecoration(
      color: Color.fromRGBO(43, 46, 66, 1),
      border: Border.all(
        color: Color.fromRGBO(126, 203, 224, 1),
      ),
      borderRadius: BorderRadius.circular(10.0));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldkey,
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 217, 251, 253),
          title: Text("S  E  L  F  M  E  T  E  R",
              style: GoogleFonts.lato(color: Colors.black))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 40),
              child: Text("OTP Verification",
                  style: GoogleFonts.asap(
                      color: Colors.black,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold)),
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              child: Center(
                child: Text("Verify +852-${widget.phone}",
                    style: GoogleFonts.asap(
                        color: Colors.black,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: true,
                obscuringCharacter: "*",
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                ),
                animationDuration: Duration(milliseconds: 300),
                onCompleted: (value) async {
                  try {
                    await FirebaseAuth.instance
                        .signInWithCredential(PhoneAuthProvider.credential(
                            verificationId: _verificationCode, smsCode: value))
                        .then((value) async {
                      if (value.user != null) {
                        setPassword(value.user!.uid);
                      }
                    });
                  } catch (e) {
                    FocusScope.of(context).unfocus();
                    if (_scaffoldkey.currentState != null) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text("Invalid OTP")));
                    }
                    //_scaffoldkey.currentState!.showSnackBar(const SnackBar(content: Text("Invalid OTP")));
                  }
                },
                onChanged: (value) {
                  print(value);
                  // if (mounted) {
                  //   setState(() {});
                  // }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+852${widget.phone}",
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              setPassword(value.user!.uid);
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verificationID, int? resendToken) {
          setState(() {
            print("errorrrrrrrrrrrrrrrrrrrrrrrrrrrrr");
            _verificationCode = verificationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          if (mounted) {
                    setState(() {
                      _verificationCode = verificationID;
                    });
                  }
        },
        timeout: Duration(seconds: 120));

  }

  setPassword(uid) {
    print("errorrrrrrrrrrrrrrrrrr");
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => password(widget.phone, uid)),
        (route) => false);
  }

  @override
  void initState() {
    super.initState();
    _verifyPhone();
  }
}
