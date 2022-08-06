import 'package:app/home.dart';
import 'package:app/otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'otp-logged-in.dart';
import 'registration.dart';

class phonelogin extends StatefulWidget {
  const phonelogin({Key? key}) : super(key: key);

  @override
  _phoneloginState createState() => _phoneloginState();
}

class _phoneloginState extends State<phonelogin> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldkey,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 217, 251, 253),
        title: Text("S  E  L  F  M  E  T  E  R", style: GoogleFonts.lato(color: Colors.black)),
        toolbarHeight: 46,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                    margin: EdgeInsets.only(top: 60, left: 20),
                    child: Text(
                      "Welcome Back!",
                      style: GoogleFonts.asap(color: Colors.black, fontSize: 38.0)
                      // TextStyle(
                      //     color: Colors.black,
                      //     fontSize: 30.0,
                      //     fontWeight: FontWeight.bold),
                    ),
                  ),
              Column(
                children: [
                  Container(
                    width: 300,
                    margin: EdgeInsets.only(top: 100, right: 1, left: 10),
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Color.fromRGBO(239, 239, 247, 1),
                    border: Border.all(
                      color: Colors.transparent,
                      width: 3                  
                    ),
                    ),
                    child: TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        // contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.asap(color: Colors.black, fontSize: 16.0),
                        hintText: "Your Phone Number",
                        counterText: "",
                        prefixIcon: Icon(Icons.phone),
                        prefix: Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Text("+852"),
                      )),
                      keyboardType: TextInputType.number,
                      
                      maxLength: 8,
                      //maxLengthEnforcement: MaxLengthEnforcement.none,
                    ),
                  ),
            
                  Container(
                    width: 300,
                    margin: EdgeInsets.only(top: 40, right: 1, left: 10),
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Color.fromARGB(255, 239, 239, 247),
                    border: Border.all(
                      color: Colors.transparent,
                      width: 3                  
                    ),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: _passwordcontroller,
                      autocorrect: false,
                      obscureText: true,
                      enableSuggestions: false,
                      maxLength: 15,
                      
                      textAlignVertical: TextAlignVertical.center,
                      decoration: 
                      InputDecoration(
                        // contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.asap(color: Colors.black, fontSize: 16.0),
                        hintText: "         Your Password", 
                        counterText: "",
                        prefixIcon: Icon(Icons.security),
                        prefix: Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Text(""),
                      )
                        ),
                      // const InputDecoration(
                      //     hintText: "Password", 
                      //     prefixIcon: Icon(Icons.security)),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 40, left: 150),
                      width: 150,
                      child: RawMaterialButton(
                        fillColor: Color.fromARGB(255, 217, 251, 253),
                        elevation: 0.0,
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        onPressed: () {
                          if(_phoneController.text.length==8 && _passwordcontroller.text.length>=4){
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  OTPscreenToLogin(_phoneController.text,_passwordcontroller.text)));
                          }
                          
                        },
                        child: Text(
                          "Login",
                          style: GoogleFonts.asap(color: Color.fromARGB(255, 21, 48, 99), fontSize: 20.0, fontWeight: FontWeight.bold)
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.all(10),
                    width: double.infinity,
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Registration()));
                        },
                        child: Text(
                          "Don't have an account? Register",
                          style: GoogleFonts.asap(color: Color.fromARGB(255, 21, 48, 99), fontSize: 18),
                        )),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}