import 'dart:convert';
import 'dart:math';
import 'package:app/main.dart';
import 'package:app/phonelogin.dart';
import 'package:app/reminder.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:google_fonts/google_fonts.dart';

class password extends StatefulWidget {
  final String phone;
  final String uid;
  password(this.phone, this.uid);

  @override
  _passwordState createState() => _passwordState();
}

class _passwordState extends State<password> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  String u = "https://jsonplaceholder.typicode.com/";

  
  static String CreateCryptoRandomString() {
    final Random _random = Random.secure();
    var values = List<int>.generate(32, (i) => _random.nextInt(256));
    return base64Url.encode(values);
  }

  static String gethashedpwd(var salt, String password) {
    Hmac hmac = new Hmac(sha256, base64.decode(salt));
    Digest digest = hmac.convert(utf8.encode(password));
    return base64.encode(digest.bytes);
  }

  Future createpatient(String name, String password,var salt) async {
    
    final resoponse = http.post(
      Uri.parse('https://iefyp.ngrok.io/createpatient'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'phone_num': widget.phone,
        'salt': salt,
        'password': gethashedpwd(salt, password)
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 217, 251, 253),
          title: Text("S  E  L  F  M  E  T  E  R",
              style: GoogleFonts.lato(color: Colors.black))),
      body: SingleChildScrollView(
        child: Center(child: Column(
          children: [
            Container(
              width: 300,
              margin: EdgeInsets.only(top: 40, right: 1, left: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Color.fromARGB(255, 239, 239, 247),
                border: Border.all(color: Colors.transparent, width: 3),
              ),
              child: TextField(
                keyboardType: TextInputType.text,
                controller: _nameController,
                maxLength: 15,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                    // contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    border: InputBorder.none,
                    hintStyle:
                        GoogleFonts.asap(color: Colors.black, fontSize: 16.0),
                    hintText: "             Your Name",
                    counterText: "",
                    prefixIcon: Icon(Icons.person),
                    prefix: Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text(""),
                    )),
              ),
            ),
            Container(
              width: 300,
              margin: EdgeInsets.only(top: 30, right: 1, left: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Color.fromARGB(255, 239, 239, 247),
                border: Border.all(color: Colors.transparent, width: 3),
              ),
              child: TextField(
                keyboardType: TextInputType.text,
                controller: _passwordController,
                obscureText: true,
                maxLength: 15,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle:
                        GoogleFonts.asap(color: Colors.black, fontSize: 16.0),
                    hintText: "         Your Password",
                    counterText: "",
                    prefixIcon: Icon(Icons.security),
                    prefix: Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text(""),
                    )),
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: 30, right: 1, left: 10),
                width: 300,
                child: RawMaterialButton(
                  fillColor: Color.fromARGB(255, 217, 251, 253),
                  elevation: 0.0,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  onPressed: () {
                    if (_nameController.text.length <= 4 &&
                        _scaffoldkey.currentState != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text("Name should be minimum 4 characters")));
                      return;
                    }
                    if (_passwordController.text.length < 4 &&
                        _scaffoldkey.currentState != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text("Password should be minimum 4 characters")));
                    }
                    var salt = CreateCryptoRandomString();
                    Map userDetails = {
                      "mobile": widget.phone,
                      "password": gethashedpwd(salt, _passwordController.text),
                      "name": _nameController.text,
                      "salt": salt,
                      "expireDate": DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                              DateTime.now().hour,
                              DateTime.now().minute)
                          .toString()
                    };
                    createpatient(
                        _nameController.text, _passwordController.text,salt);
                    dbRef.child(widget.uid).set(userDetails).then((value) {
                      print("database wrong");

                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Reminder()),
                          (route) => false);
                    }).onError((error, stackTrace) {
                      print("errrrrror");
                      if (_scaffoldkey.currentState != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${error.toString()}")));
                      }
                    }).catchError((e){
                      print("catch error");
                      return Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => phonelogin()),
                          (route) => false);
                    });
                  },
                  child: Text("Next",
                      style: GoogleFonts.asap(
                          color: Color.fromARGB(255, 21, 48, 99),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold)),
                ))
          ],
        ),)
        
      ),
    );
  }
}
