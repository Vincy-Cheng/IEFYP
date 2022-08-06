import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:app/function.dart';
import 'package:app/reminder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/phonelogin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class setting extends StatefulWidget {
  const setting({Key? key}) : super(key: key);

  @override
  State<setting> createState() => _settingState();
}

class _settingState extends State<setting> {
  int _counter = 0;
  static TimeOfDay wake = TimeOfDay(hour: 8, minute: 30); // 08:00 a.m.
  static TimeOfDay sleep = TimeOfDay(hour: 22, minute: 30);
  String _wakeup = wake.hour.toString() + ":" + wake.minute.toString();
  String _sleeping = sleep.hour.toString() + ":" + sleep.minute.toString();
  //Set back time
  //TimeOfDay _startTime = TimeOfDay(hour:int.parse(s.split(":")[0]),minute: int.parse(s.split(":")[1]));
  void _loadtime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = (prefs.getInt('counter') ?? 0);
      _wakeup = (prefs.getString('wakeup') ?? _wakeup);
      _sleeping = (prefs.getString('sleeping') ?? _sleeping);
      selectedwakeTime = TimeOfDay(
          hour: int.parse(_wakeup.split(":")[0]),
          minute: int.parse(_wakeup.split(":")[1]));
      selectedsleepTime = TimeOfDay(
          hour: int.parse(_sleeping.split(":")[0]),
          minute: int.parse(_sleeping.split(":")[1]));
    });
  }

  //Incrementing counter after click
  void _incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = (prefs.getInt('counter') ?? 0) + 1;
      prefs.setInt('counter', _counter);
      _wakeup = "08:30";
      _sleeping = "16:00";
      prefs.setString('wakeup', _wakeup);
      prefs.setString('sleeping', _sleeping);
    });
  }

  late TimeOfDay selectedwakeTime = TimeOfDay(
      hour: int.parse(_wakeup.split(":")[0]),
      minute: int.parse(_wakeup.split(":")[1]));
  late TimeOfDay selectedsleepTime = TimeOfDay(
      hour: int.parse(_sleeping.split(":")[0]),
      minute: int.parse(_sleeping.split(":")[1]));
  @override
  Widget build(BuildContext context) {
    //Navigator.of(context).pop('String');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: Color.fromARGB(255, 217, 251, 253),
          title: Text("S  E  L  F  M  E  T  E  R",
              style: GoogleFonts.lato(color: Colors.black))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: 30.0),
                width: 150,
                child: RawMaterialButton(
                  fillColor: Color.fromARGB(255, 217, 251, 253),
                  elevation: 10.0,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  onPressed: () {
                    _selectwakeTime(context);
                  },
                  child: Text("Wake up time",
                      style: GoogleFonts.asap(
                          color: Color.fromARGB(255, 21, 48, 99),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold)),
                )),
            Container(
                margin: EdgeInsets.only(top: 30.0),
                width: 150,
                child: RawMaterialButton(
                  fillColor: Color.fromARGB(255, 217, 251, 253),
                  elevation: 10.0,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  onPressed: () {
                    _selectsleepTime(context);
                  },
                  child: Text("Sleeping time",
                      style: GoogleFonts.asap(
                          color: Color.fromARGB(255, 21, 48, 99),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold)),
                )),
            Container(
                margin: EdgeInsets.only(top: 30.0),
                width: 200,
                child: RawMaterialButton(
                  fillColor: Color.fromARGB(255, 21, 48, 99),
                  elevation: 10.0,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  onPressed: () async {
                    Navigator.of(context).pushReplacement(new MaterialPageRoute(
                        builder: (context) => Reminder()));
                  },
                  child: Text("Back to reminder",
                      style: GoogleFonts.asap(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold)),
                )),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                    margin: EdgeInsets.only(bottom: 20, right: 20),
                    width: 150,
                    child: RawMaterialButton(
                      fillColor: Color.fromARGB(255, 21, 48, 99),
                      elevation: 10.0,
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => phonelogin()));
                      },
                      child: Text("Sign out",
                          style: GoogleFonts.asap(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold)),
                    )),
              ),
            )
          ],
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _selectwakeTime(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedwakeTime,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (timeOfDay != null) {
      setState(() {
        String _wakeuphour = timeOfDay.hour.toString();
        if (int.parse(_wakeuphour) / 10 == 0) {
          _wakeuphour = "0" + _wakeup;
        }
        String _wakeupmintues = timeOfDay.minute.toString();
        //"08:00"
        _wakeup = _wakeuphour + ":" + _wakeupmintues;
        prefs.setString('wakeup', _wakeup);
        selectedwakeTime = timeOfDay;
      });
    }
  }

  _selectsleepTime(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedsleepTime,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (timeOfDay != null) {
      setState(() {
        String _sleephour = timeOfDay.hour.toString();
        if (int.parse(_sleephour) / 10 == 0) {
          _sleephour = "0" + _wakeup;
        }
        String _wakeupmintues = timeOfDay.minute.toString();
        //"08:00"
        _sleeping = _sleephour + ":" + _wakeupmintues;
        prefs.setString('sleeping', _sleeping);
        selectedsleepTime = timeOfDay;
        print("slected time" + selectedsleepTime.toString());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadtime();
  }
}
