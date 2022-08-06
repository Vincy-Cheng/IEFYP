import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:app/function.dart';
import 'package:app/reminder.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class Camera extends StatefulWidget {
  //const Camera({Key? key}) : super(key: key);
  final int prescriptionNum;
  Camera(this.prescriptionNum);
  @override
  _CameraState createState() => _CameraState();
}

class Prescription {
  final int id;
  final double width;
  final double height;
  final String name;
  final String shape;
  final String color;
  final int qty;
  bool isFound;
  Prescription(this.id, this.width, this.height, this.name, this.shape,
      this.color, this.qty, this.isFound);
}

late List<Prescription> pp = [];

class _CameraState extends State<Camera> {
  String url = "";
  String u = "https://iefyp.ngrok.io";
  // String u = "https://0e375afd8277.ngrok.io";
  var data;
  String output = 'Initial Output';

  get itemBuilder => null;
  List d = [];
  List datanew = []; // anaylzed photo data
  File? selectedImage;
  String? message = "";
  List<List<String>> s = [];
  bool PillAllMatch = true;
  bool CheckMatch = false;

  Future uploadImage() async {
    final request = await http.MultipartRequest(
        // url need to change everytime run the app.py
        "POST",
        Uri.parse(u + "/upload"));

    final header = {"Content-type": "multipart/form-data"};

    request.files.add(http.MultipartFile('image',
        selectedImage!.readAsBytes().asStream(), selectedImage!.lengthSync(),
        filename: selectedImage!.path.split("/").last));

    request.headers.addAll(header);
    final response = await request.send();

    processImage();
    setState(() {});
  }

  getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    try {
      selectedImage = File(image!.path);
      uploadImage();
      setState(() {});
    } catch (e) {}
  }

  processImage() async {
    // change query to session ID
    url = u + '/api?query=a'; //+ value.toString();
    data = await fetchdata(url);
    try {
      if (data != null) {
        datanew = json.decode(data);
        countsamepill(datanew);
      }
    } catch (e) {}
  }

  //Prescription(this.id, this.width, this.height, this.shape, this.color,this.isFound);
  countsamepill(List comparedata) {
    int count_num =1;
    if (pp.isNotEmpty) {
      
      for (var item in pp) {
        print("count_num:"+count_num.toString());
        for (var i = 1; i < comparedata.length; i++) {
          double errorwidth = (item.width / comparedata[i]["width"] - 1).abs();
          double errorheight =
              (item.height / comparedata[i]["height"] - 1).abs();
          if (item.color == comparedata[i]["color"] &&
              item.shape == comparedata[i]["shape"] &&
              errorwidth <= 0.1 &&
              errorheight <= 0.1) {
            item.isFound = true;
            print("matched"+item.name);
            break;
          }
        }
        count_num++;
      }
      for (var item in pp) {
        if (item.isFound == false) {
          PillAllMatch = false;
          
          break;
        }
      }
      CheckMatch = true;
    }

    setState(() {
      if (PillAllMatch) {
        CheckeventList[widget.prescriptionNum].isFinish = true;
      }
    });

    for (var item in comparedata) {
      print("shape: "+ item["shape"]+",color: "+ item["color"]+",width: "+ item["width"].toString()+",height: "+ item["height"].toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 217, 251, 253),
          foregroundColor: Colors.black,
          title: Text("S  E  L  F  M  E  T  E  R",
              style: GoogleFonts.lato(color: Colors.black))),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Recipe:",
                  style: GoogleFonts.asap(fontSize: 30),
                ),
                SizedBox(
                  height: 20,
                ),
                Table(
                  //border: TableBorder.all(),
                  children: <TableRow>[
                    TableRow(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 10.0, right: 10),
                          child: Text(
                            "Name",
                            style: GoogleFonts.asap(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10.0, right: 10),
                          child: Text(
                            "Color",
                            style: GoogleFonts.asap(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            "Shape",
                            style: GoogleFonts.asap(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10.0, left: 10),
                          child: Text(
                            "Quantity",
                            style: GoogleFonts.asap(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    for (var item in pp)
                      TableRow(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(bottom: 10.0, right: 10),
                            child: Text(
                              item.name,
                              style: GoogleFonts.asap(fontSize: 20),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 10.0, right: 10),
                            child: Text(
                              item.color,
                              style: GoogleFonts.asap(fontSize: 20),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              item.shape,
                              style: GoogleFonts.asap(fontSize: 20),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 10.0, left: 10),
                            child: Text(
                              item.qty.toString(),
                              style: GoogleFonts.asap(fontSize: 20),
                            ),
                          ),
                        ],
                      )
                  ],
                ),
                SizedBox(
                  height: 120,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text("Click Camera to upload image",
                      style:
                          GoogleFonts.asap(fontSize: 30, color: Colors.green),
                      textAlign: TextAlign.center),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    d = [];
                    await getImage();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 21, 48, 99),
                    elevation: 10.0, // background color
                    minimumSize: Size(80, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                Container(
                  child: Row(
                    children: <Widget>[
                      //Text("Text1"),

                      if (PillAllMatch == true && CheckMatch == true)
                        Text(
                          "Pill all matched",
                          style: GoogleFonts.asap(
                              fontSize: 20, ),
                        ),

                      if (PillAllMatch == false && CheckMatch == true)
                        Text(
                          "All pill matched",
                          style: GoogleFonts.asap(
                              fontSize: 20, ),
                        )
                    ],
                  ),
                )
                //Text(
                //  output.toString(),
                //  style: TextStyle(fontSize: 40, color: Colors.green),
                //),
                //Container(child:Image.file(selectedImage!)),
                // Expanded(
                //     child: ListView.builder(
                //         itemCount: datanew.length,
                //         itemBuilder: (BuildContext ctxt, int index) {
                //           print(datanew.length);

                //           return Text(datanew[index]["color"]);
                //         })),
                // Text(prescription[0]["pill_id"].toString()),
              ]),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     //print(d[1][0]);
      //     print(datanew.length);
      //   },
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
