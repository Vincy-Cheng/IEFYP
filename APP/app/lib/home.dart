import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:app/function.dart';
import 'package:app/login.dart';
import 'package:app/phonelogin.dart';
import 'package:app/reminder.dart';
import 'package:app/setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'camera.dart';
import 'calendar.dart';
import 'main.dart';
import 'otp-logged-in.dart';
import 'setting.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List pilldata = [];
  bool? checkimage;

  int _counter = 0;

  checkexpiredate() async {
    DatabaseReference DE = dbRef.child(currentuser!.uid);
    DatabaseEvent dataE = await DE.once();
    if (dataE.snapshot.exists) {
      DateTime edate = DateTime.parse(
          dataE.snapshot.child("expireDate").value.toString());
      if (DateTime.now().isAfter(edate)) {
        FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => phonelogin()));
      }
    } else {
      print("no element");
      //print(currentuser!.uid);
    }
    // print(dataE.snapshot.children);
    // print(dataE.snapshot.value);
    // print("end");
    // DatabaseEvent kevent = await dbRef.once();
    // DatabaseReference kk = dbRef.child(currentuser!.uid);
    // DatabaseEvent hh = await kk.once();
    // print(hh.snapshot.children.length);
  }

  @override
  void initState() {
    super.initState();

    checkexpiredate();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title ?? ''),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body ?? '')],
                  ),
                ),
              );
            });
      }
    });
  }

  void showNotification() {
    setState(() {
      _counter++;
    });
    flutterLocalNotificationsPlugin.show(
        0,
        "Testing $_counter",
        "How you doin ?",
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description,
                importance: Importance.high,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Center(child: Icon(Icons.abc_sharp,size: 50,color: Colors.white,),),
        
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/morning.jpg",
                    height: 300,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Camera(1)),
                      );
                    },
                    icon: Icon(
                      Icons.add_a_photo,
                      color: Colors.black87,
                      size: 100,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Reminder()),
                      );
                    },
                    icon: Icon(
                      Icons.remember_me,
                      color: Colors.black87,
                      size: 100,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Calendar()),
                      );
                    },
                    icon: Icon(
                      Icons.calendar_today,
                      color: Colors.black87,
                      size: 100,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 100.0,
              ),
              Center(
                child: MaterialButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => phonelogin()));
                  },
                  child: Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
              Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
              SizedBox(
                height: 100.0,
              ),
              Center(
                child: MaterialButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  onPressed: () async {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => setting()));
                  },
                  child: Text(
                    "setting",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showNotification,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
      
    );
  }
}
