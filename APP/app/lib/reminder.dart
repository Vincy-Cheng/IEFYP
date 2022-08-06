import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:app/function.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'camera.dart';
import 'custom_icon_decoration.dart';
import 'package:intl/intl.dart';
import 'package:app/setting.dart';
import 'main.dart';
import 'package:google_fonts/google_fonts.dart';

class Reminder extends StatefulWidget {
  const Reminder({Key? key}) : super(key: key);

  @override
  _ReminderState createState() => _ReminderState();
}

TimeOfDay wake = TimeOfDay(hour: 8, minute: 00); // 08:00 a.m.
TimeOfDay sleep = TimeOfDay(hour: 22, minute: 30); // 10:00 p.m
int _counter = 0;
String _wakeup = wake.hour.toString() + ":" + wake.minute.toString();
String _sleeping = sleep.hour.toString() + ":" + sleep.minute.toString();

class Event {
  final DateTime time;
  final String task;
  final String desc;
  bool isFinish;
  final int id;

  Event(this.time, this.task, this.desc, this.isFinish, this.id);
}

final List<Event> eventList = [
  // new Event("08:00", "Have coffe with Sam", "Personal", true),
  // new Event("10:00", "Meet with sales", "Work", true),
  // new Event("12:00", "Call Tom about appointment", "Work", false),
  // new Event("14:00", "Fix onboarding experience", "Work", false),
  // new Event("16:00", "Edit API documentation", "Personal", false),
  // new Event("18:00", "Setup user focus group", "Personal", false),
];

late List<Event> CheckeventList = [];
int loadlisttime = 1;

late List<dynamic> prescription;

class _ReminderState extends State<Reminder> {
  @override
  void initState() {
    super.initState();
    _loadtime();
  }

  @override
  void dispose() {
    super.dispose();
  }

  static DateTime Today = DateTime.now();

  Future login() async {
    DatabaseReference DE = dbRef.child(currentuser!.uid);
    DatabaseEvent prescr = await DE.once();
    // retrieve data from web portal
    final response = await http.post(
      Uri.parse('https://iefyp.ngrok.io/getprescript'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': prescr.snapshot.child("name").value.toString(),
        'password': prescr.snapshot.child("password").value.toString()
      }),
    );
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        // print((response.body));
        var j = json.decode(response.body);
        eventList.clear();
        pp.clear();
        addtimeslot(j);
        prescription = j;
      }
    }
  }

  void addtimeslot(var j) {
    // print("add timw slot");
    // print(eventList.length);
    // print("j length "+j.length.toString());
    int indexforP = 1;
    for (var item in j) {
      //each pill
      int f = int.parse(item["frequence"]); // means hours/times
      //int period =
      DateTime n = DateTime.now();
      DateTime wakeupTime =
          DateTime(n.year, n.month, n.day, wake.hour, wake.minute);
      DateTime sleepTime =
          DateTime(n.year, n.month, n.day, sleep.hour, sleep.minute);
      final difference =
          sleepTime.difference(wakeupTime); // 08:00 -22:00 = 14 hours
      int times = difference.inHours.toInt() ~/ f; // difference /freq
      pp.add(Prescription(
          indexforP,
          double.parse(item["pill_w"]),
          double.parse(item["pill_h"]),
          item["pill_name"],
          item["pill_shape"],
          item["pill_color"],
          int.parse(item["qty"]),
          false));
      //print("times = "+times.toString());
      for (var i = 0; i <= times; i++) {
        //print("i="+i.toString());
        var time = wakeupTime.add(Duration(hours: f * i));

        var trendName = time;
        int trendIndex =
            eventList.indexWhere((element) => element.time == trendName);

        if (trendIndex == -1) {
          var total = {"Total": int.parse(item["qty"])};
          eventList.add(Event(time, item["pill_name"], json.encode(total),
              false, indexforP - 1));
          //print(time.toString());
        } else {
          var total = json.decode(eventList[trendIndex].desc);
          String temp = eventList[trendIndex].task;
          var qtotal = {"Total": total["Total"] + int.parse(item["qty"])};

          eventList[trendIndex] = Event(time, temp + ", " + item["pill_name"],
              json.encode(qtotal), false, indexforP - 1);
          //print(time.toString());
        }
      }
      indexforP++;
    }
    if (mounted) {
      setState(() {
        //print("sort");
        eventList.sort(((a, b) => a.time.compareTo(b.time)));
        //print(eventList.length.toString()+" after sort");
        if (loadlisttime == 1) {
          CheckeventList = [...eventList];
        }
        loadlisttime++;
        checktime();
      });
    }
  }

  void checkeventlist() {
    List re = [];
    for (var i = 0; i < eventList.length; i++) {
      // print(eventList[i].isFinish);
      // print("hi");
      // print(CheckeventList[i].isFinish);
      if (eventList[i].isFinish != CheckeventList[i].isFinish) {
        re.add(i);
      }
    }
    re.sort();
    //print("re");
    //print(re.length);
    for (var i = re.length - 1; i >= 0; i--) {
      //print(i);
      //print("remove");
      setState(() {
        eventList.removeAt(re[i]);
      });
    }
    setState(() {
      
    });
  }

  void checktime() {
    for (var item in CheckeventList) {
      if (DateTime.now().isAfter(item.time)) {
        // print(DateTime.now());
        // print(item.time);
        item.isFinish = true;
      }
    }

    checkeventlist();
    //print(eventList.length);
  }

  Future _loadtime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      print("load time");
      _counter = (prefs.getInt('counter') ?? 0);
      _wakeup = (prefs.getString('wakeup') ?? _wakeup);
      _sleeping = (prefs.getString('sleeping') ?? _sleeping);
      wake = TimeOfDay(
          hour: int.parse(_wakeup.split(":")[0]),
          minute: int.parse(_wakeup.split(":")[1]));
      sleep = TimeOfDay(
          hour: int.parse(_sleeping.split(":")[0]),
          minute: int.parse(_sleeping.split(":")[1]));
    });
    await login();
  }

  @override
  Widget build(BuildContext context) {
    double iconSize = 20;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 217, 251, 253),
        title: Text("S  E  L  F  M  E  T  E  R",
            style: GoogleFonts.lato(color: Colors.black)),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _loadtime();
                    print(eventList.length);
                  });
                },
                child: Icon(
                  Icons.refresh,
                  size: 26.0,
                ),
              )),
        ],
      ),
      body: Container(
        color: Color.fromARGB(255, 255, 255, 255),
        //color: Color.fromARGB(255, 214, 212, 212),
        child: Column(children: [
          Container(
              margin: EdgeInsets.only(bottom: 50.0),
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24, top: 10),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(DateFormat('EEEE').format(Today),
                          style: GoogleFonts.asap(
                              color: Color.fromARGB(255, 54, 80, 102),
                              fontSize: 60)
                          //TextStyle(fontSize: 60, color: Colors.blueGrey),
                          ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        DateFormat.yMd().format(Today),
                        style: GoogleFonts.asap(
                            color: Color.fromARGB(255, 54, 80, 102),
                            fontSize: 30),
                      ),
                    )
                  ],
                ),
              )),
          Expanded(
              child: ListView.builder(
            itemCount: eventList.length,
            padding: const EdgeInsets.all(0),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24),
                child: Row(
                  children: <Widget>[
                    _lineStyle(context, iconSize, index, eventList.length,
                        eventList[index].isFinish),
                    _displayTime(eventList[index].time.hour.toString() +
                        ":" +
                        eventList[index].time.minute.toString()),
                    _displayContent(eventList[index])
                  ],
                ),
              );
            },
          ))
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => setting()));
        },
        tooltip: 'Setting',
        backgroundColor: Colors.blueGrey,
        child: Icon(Icons.settings),
      ),
    );
  }

  Widget _lineStyle(BuildContext context, double iconSize, int index,
      int listLength, bool isFinish) {
    return Container(
        decoration: CustomIconDecoration(
            iconSize: iconSize,
            lineWidth: 3,
            firstData: index == 0,
            lastData: index == listLength - 1),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 3),
                      color: Color(0x20000000),
                      blurRadius: 5)
                ]),
            child: Icon(
                isFinish
                    ? Icons.fiber_manual_record
                    : Icons.radio_button_unchecked,
                size: iconSize,
                color: Color.fromARGB(255, 54, 80, 102)) // circle color
            //Theme.of(context).accentColor),
            ));
  }

  Widget _displayContent(Event event) {
    return Expanded(
      child: Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Camera(event.id)),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(239, 239, 247, 1),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x20000000),
                        blurRadius: 5,
                        offset: Offset(0, 3))
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(event.task,
                      style:
                          GoogleFonts.asap(color: Colors.black, fontSize: 30)),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    event.desc,
                    style: GoogleFonts.asap(color: Colors.black, fontSize: 30),
                  )
                ],
              ),
            ),
          )),
    );
  }

  Widget _displayTime(String time) {
    return Container(
        width: 80,
        margin: EdgeInsets.only(right: 30.0),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(time,
              style: GoogleFonts.asap(
                  color: Color.fromARGB(255, 54, 80, 102), fontSize: 30)),
        ));
  }
}
