// ignore_for_file: unused_import, use_key_in_widget_constructors, prefer_const_constructors, file_names

import 'dart:convert';
import 'dart:ffi';

import 'package:app/camera.dart';
import 'package:app/password.dart';
import 'package:app/reminder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:crypto/crypto.dart';
import 'home.dart';
import 'main.dart';
import 'phonelogin.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

class OTPscreenToLogin extends StatefulWidget {
  final String phone;
  final String password;
  // ignore: prefer_const_constructors_in_immutables
  OTPscreenToLogin(this.phone, this.password);
  @override
  _OTPscreenToLoginState createState() => _OTPscreenToLoginState();
}

class _OTPscreenToLoginState extends State<OTPscreenToLogin> {
  static DateTime Today = DateTime.now();
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

  static String gethashedpwd(var salt, String password){
    
    Hmac hmac = new Hmac(sha256, base64.decode(salt));
    Digest digest = hmac.convert(utf8.encode(password));
    return base64.encode(digest.bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldkey,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 217, 251, 253),
        foregroundColor: Color.fromARGB(255, 0, 0, 0),
        title: Text("S  E  L  F  M  E  T  E  R", style: GoogleFonts.lato(color: Colors.black))
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 40),
              child: Text(
                "OTP Verification",
                style: GoogleFonts.asap(color: Colors.black, fontSize: 30.0, fontWeight: FontWeight.bold)
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  "Verify +852-${widget.phone}",
                  style: GoogleFonts.asap(color: Colors.black, fontSize: 22.0, fontWeight: FontWeight.bold)
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: true,
                obscuringCharacter: "*",
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                animationDuration: Duration(milliseconds: 300),
                onCompleted: (pin) async {
                  try {
                    await FirebaseAuth.instance
                        .signInWithCredential(PhoneAuthProvider.credential(
                            verificationId: _verificationCode, smsCode: pin))
                        .then((value) async {
                      if (value.user != null) {
                        setState(() {
                          currentuser = value.user;
                        });
                        print(currentuser!.uid);
                        print("okkkkkkk");
                        bool checkuser = false;
                        DatabaseReference DE = dbRef.child(currentuser!.uid);
                        DatabaseEvent event = await DE.once();
                        print(event.snapshot.child("mobile").value);
                        print(event.snapshot.child("password").value);
                        //print(widget.phone);
                        //print(widget.password);
                        print(event.snapshot.children.length);
                        if (event.snapshot.children.length > 0) {
                          print("have child");
                          String pwd = gethashedpwd(event.snapshot.child("salt").value, widget.password.toString());
                          if (event.snapshot.child("mobile").value ==
                                  widget.phone.toString() &&
                              event.snapshot.child("password").value == pwd) {
                            checkuser = true;
                            DateTime expiredDate = DateTime(
                                Today.year,
                                Today.month,
                                Today.day,
                                Today.hour,
                                Today.minute + 3);
                            await DE.update({
                              "expireDate": DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month+3,
                                      DateTime.now().day,
                                      DateTime.now().hour,
                                      DateTime.now().minute)
                                  .toString(),
                            });
                            print("to reminder");
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => Reminder()),
                                (route) => false);
                          }
                          else{
                            print("wrong email or pwd");
                          }
                        }else{
                          
                        }

                        if (!checkuser) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => phonelogin()),
                              (route) => false);
                        }

                        //print(event.snapshot.value);

                        //print(event.snapshot.children.length);
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
                  if (value == null) {
                    setState(() {});
                  }
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
              final check = await dbRef.key;
              print("verrrrr");
              // print(check);
              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(builder: (context) => Home()),
              //     (route) => false);
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verificationID, int? resendToken) {
          setState(() {
            _verificationCode = verificationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {},
        timeout: Duration(seconds: 120));
  }

  @override
  void initState() {
    super.initState();
    _verifyPhone();
  }
}