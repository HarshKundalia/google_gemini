// ignore_for_file: unused_field, prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class Imagechat extends StatefulWidget {
  const Imagechat({super.key});

  @override
  State<Imagechat> createState() => _ImagechatState();
}

class _ImagechatState extends State<Imagechat> {
  XFile? pickedImage;
  String mytext = '';
  bool scanning = false;

  TextEditingController prompt = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  final apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyAtbADpNiAyPJiD9I55h46o_lEVouig6R0';

  final header = {
    'Content-Type': 'application/json',
  };

  getImage(ImageSource ourSource) async {
    XFile? result = await _imagePicker.pickImage(source: ourSource);

    if (result != null) {
      setState(() {
        pickedImage = result;
      });
    }
  }

  getdata(image, promptValue) async {
    setState(() {
      scanning = true;
      mytext = '';
    });

    try {
      List<int> imageBytes = File(image.path).readAsBytesSync();
      String base64File = base64.encode(imageBytes);

      final data = {
        "contents": [
          {
            "parts": [
              {"text": promptValue},
              {
                "inlineData": {
                  "mimeType": "image/jpeg",
                  "data": base64File,
                }
              }
            ]
          }
        ],
      };

      // Log the request payload
      print('Request Payload: ${jsonEncode(data)}');

      await http
          .post(Uri.parse(apiUrl), headers: header, body: jsonEncode(data))
          .then((response) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          setState(() {
            mytext = result['candidates'][0]['content']['parts'][0]['text'];
          });
        } else {
          setState(() {
            mytext =
                'Response status : ${response.statusCode}\nResponse body: ${response.body}';
          });
        }
      }).catchError((error) {
        setState(() {
          mytext = 'Error occurred: $error';
        });
      });
    } catch (e) {
      setState(() {
        mytext = 'Error occurred: $e';
      });
    }

    setState(() {
      scanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Google Gemini',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'CustomFont'),
        ),
        // centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              getImage(ImageSource.gallery);
            },
            icon: Icon(
              Icons.photo,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            pickedImage == null
                ? Container(
                    height: 340,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        'No Image Selected',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ))
                : Container(
                    height: 340,
                    child: Center(
                        child: Image.file(
                      File(pickedImage!.path),
                      height: 400,
                    ))),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: prompt,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                prefixIcon: Icon(
                  Icons.pending_sharp,
                  color: Colors.black,
                ),
                hintText: 'Enter your prompt here',
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: () {
                getdata(pickedImage, prompt.text);
              },
              icon: Icon(Icons.generating_tokens_rounded),
              label: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Generate Answer',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            ),
            SizedBox(
              height: 30,
            ),
            scanning
                ? Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(
                      child: SpinKitThreeBounce(
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  )
                : Text(
                    mytext,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  )
          ],
        ),
      ),
    );
  }
}
