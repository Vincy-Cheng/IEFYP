// ignore_for_file: file_names

import 'package:app/otp.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Color.fromARGB(255, 217, 251, 253),
        title: Text("S  E  L  F  M  E  T  E  R", style: GoogleFonts.lato(color: Colors.black))
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 60),
                  child: Center(
                    child: 
                    Text(
                      "SignUp with your mobile phone",
                      style: GoogleFonts.asap(color: Colors.black, fontSize: 25.0)
                    ),
                  
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 60, right: 10, left: 10),
                  width: 300,
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Color.fromRGBO(239, 239, 247, 1),
                  border: Border.all(
                    color: Colors.transparent,
                    width: 3                  
                  ),),
                  child: 
                  TextField(
                      controller: _controller,
                      decoration: InputDecoration(
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
                    ),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 50, left: 140),
              width: 150,
              child: 
              RawMaterialButton(
                        fillColor: Color.fromARGB(255, 217, 251, 253),
                        elevation: 0.0,
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => OTPscreen(_controller.text)));                                                   
                        },
                        child: Text(
                          "Next",
                          style: GoogleFonts.asap(color: Color.fromARGB(255, 21, 48, 99), fontSize: 20.0, fontWeight: FontWeight.bold)
                        ),
                      )
              
              // MaterialButton(
              //   onPressed: () {
              //     Navigator.of(context).pushReplacement(MaterialPageRoute(
              //         builder: (context) => OTPscreen(_controller.text)));
              //   },
              //   color: Colors.blue,
              //   child: 
              //   Text(
              //             "Next",
              //             style: GoogleFonts.asap(color: Color.fromARGB(255, 21, 48, 99), fontSize: 20.0, fontWeight: FontWeight.bold)
              //           ),
              // ),
            )
          ],
        ),
      ),
    );
  }
}