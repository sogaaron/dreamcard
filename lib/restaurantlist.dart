// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:geoflutterfire/geoflutterfire.dart';

class RestaurantList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Restaurant List'),
          backgroundColor: Colors.lightBlueAccent,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                semanticLabel: 'back_to_main',
              ),
              onPressed: () => Navigator.pop(context)
          ),
        ),
        body: Favorite(),
      ),
    );
  }
}


class Favorite extends StatefulWidget {
  @override
  FavoriteState createState() {
    return FavoriteState();
  }
}


class FavoriteState extends State<Favorite> {
  Firestore firestore=Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
      floatingActionButton: new FloatingActionButton(onPressed: (){
        _settingModalBottomSheet(context);
      },
        child: Icon(Icons.add),
      ),
    );
  }


  void _settingModalBottomSheet(BuildContext context) async {
    //location, phone_number, URL, restaurant_type, name, opening_hours
    final myController = TextEditingController();
    //final locationController = TextEditingController();
    final nameController= TextEditingController();
    final phone_numberController= TextEditingController();
    final URLController= TextEditingController();
    final restaurant_typeController= TextEditingController();
    final opening_hoursController= TextEditingController();

    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                        labelText: 'name'
                    ),
                  ),
                  TextField(
                    controller: restaurant_typeController,
                    decoration: InputDecoration(
                        labelText: 'restaurant_type'
                    ),
                  ),
                  TextField(
                    controller: phone_numberController,
                    decoration: InputDecoration(
                        labelText: 'phone_number'
                    ),
                  ),
                  TextField(
                    controller: opening_hoursController,
                    decoration: InputDecoration(
                        labelText: 'opening_hours'
                    ),
                  ),
                  TextField(
                    controller: URLController,
                    decoration: InputDecoration(
                        labelText: 'URL'
                    ),
                  ),
//                TextField(
//                  controller: locationController,
//                  decoration: InputDecoration(
//                      labelText: 'location'
//                  ),
//                ),
                ],
              )
          ),

          actions: <Widget>[
            FlatButton(
              child: Text('Add'),
              onPressed: () {
                Navigator.pop(context);
                print("Data Add : "+nameController.text);
                firestore.collection('restaurant').document(nameController.text).setData({
                  'restaurant_type':restaurant_typeController.text,'phone_number':phone_numberController.text,'opening_hours':opening_hoursController.text,
                  'URL':URLController.text,'name':nameController.text,'like':0,
                });
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
                print("cancel");
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    // TODO: get actual snapshot from Cloud Firestore
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('restaurant').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.ename),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.name),
          leading: IconButton(
            //padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            icon : Icon(
              record.like.toString()=='0'  ? Icons.favorite_border : Icons.favorite,
              color: record.like.toString()=='0' ? null : Colors.red,
            ),
            onPressed: (){
              record.like.toString()=='0' ? firestore.collection("restaurant").document(record.ename).updateData(
                  {"like": 1}) :
              firestore.collection("restaurant").document(record.ename).updateData(
                  {"like": 0});
            },
          ),
          trailing:Wrap(
            spacing: 0,
            children:[
              Column(
                children: <Widget>[
//                  Container(
//                    padding: const EdgeInsets.all(0),
//                    height: 35,
//                    child:(
//                        IconButton(
//                          //padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
//                          icon : Icon(
//                              record.like.toString()=='0'  ? Icons.favorite_border : Icons.favorite,
//                              color: record.like.toString()=='0' ? null : Colors.red,
//                          ),
//                          onPressed: (){
//                            record.like.toString()=='0' ? firestore.collection("restaurant").document(record.name).updateData(
//                                {"like": 1}) :
//                            firestore.collection("restaurant").document(record.name).updateData(
//                               {"like": 0});
//                          },
//                        )
//                    ),
//                  ),
                  //Text(record.like.toString())
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(0),
                    height: 35,
                    child:(
                        IconButton(
                          //padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          icon : Icon(Icons.search),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => MyWebView(
                                  title: record.name,
                                  selectedUrl: record.URL.toString(),
                                )));
                          },
                        )
                    ),
                  ),
                ],
              )
            ],

          )
          ,
        ),
      ),
    );
  }
}

class Record {
  final String name;
  final int like;
  final DocumentReference reference;
  //final String location;
  final String phone_number;
  final String URL;
  final String restaurand_type;
  final String opening_hours;
  final String ename;


  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        name = map['name'],
        like=map['like'],
        phone_number=map['phone_number'],
        URL=map['URL'],
        restaurand_type=map['restaurand_type'],
        ename=map['ename'],
        opening_hours=map['opening_hours'];
  //location=map['location'];



//location, phone_number, URL, restaurant_type, name, opening_hours
  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$name>";
}







//webview
class MyWebView extends StatelessWidget {
  final String title;
  final String selectedUrl;

  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  MyWebView({
    @required this.title,
    @required this.selectedUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          title: Text(title),
        ),
        body: WebView(
          initialUrl: selectedUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
        ));
  }
}