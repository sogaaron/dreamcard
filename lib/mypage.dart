// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';



// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

//import 'package:Shrine/signin.dart';
import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:basic_utils/basic_utils.dart';
import 'signin_page.dart';


class ProfilePage extends StatefulWidget {
  final FirebaseStorage storage = FirebaseStorage.instance;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  Firestore firestore=Firestore.instance;
  String email, url;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<StorageUploadTask> _tasks = <StorageUploadTask>[];
  File _image;
  String _uploadedFileURL;
  Map<String, Object> product_info = HashMap();
  String name;
  String budget;

  Widget _buildBody(BuildContext context) {
    // TODO: get actual snapshot from Cloud Firestore
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('user').where('uid', isEqualTo: SignInPage.uid_now).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        url=snapshot.data.documents[0]['image'].toString();
        name=snapshot.data.documents[0]['name'].toString();
        budget=snapshot.data.documents[0]['budget'].toString();
//          print("url here");
//          print(url);
        return Column(
          children: <Widget>[
            _image == null ?
            Image.network(
              url ,
//              fit: BoxFit.cover,
              width: 300,
              height: 240,
            ) :  SizedBox(
              child: Image.file(_image,
                fit: BoxFit.cover,
              ),
              width: 300,
              height: 240,
            ),
            Divider(height: 20.0, color: Colors.grey),
            Text("이름 : "+name,style: TextStyle(color: Colors.blueGrey
                ,fontWeight: FontWeight.bold,fontSize: 30.0),),
            Divider(height: 20.0, color: Colors.grey),
            Text("남아있는 잔액 : " +budget,style: TextStyle(color: Colors.blueGrey
                ,fontWeight: FontWeight.bold,fontSize: 30.0),),
            Divider(height: 20.0, color: Colors.grey),

          ],

        );
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
      key: ValueKey(record.uid),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.name),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String a;
    DocumentSnapshot b;
    DocumentReference c;
    firestore.collection('user').document(SignInPage.uid_now);
    a=firestore.collection('user').document(SignInPage.uid_now).toString();
    print("here: ");
    print(a);
    if(SignInPage.flag == 0){
      email = "anonymous";
      url =  'http://www.icons101.com/icons/88/All_Flat_Icons_by_Mahm0udWally/128/User.png';
    }
    else{
      email = SignInPage.uu.email;
      url = SignInPage.uu.photoUrl;
    }
    print("SignInPage.uid_now : ");
    print(SignInPage.uid_now);
    return MaterialApp(
      title: 'Flutter layout demo',

      home: Scaffold(
        appBar: AppBar(
          title: Text('MyPage'),
          backgroundColor: Colors.lightBlueAccent,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                semanticLabel: 'search',
              ),
              onPressed: () => Navigator.pop(context)
          ),
        ),
        body: ListView(
          children: [
//            Padding(
//              child: Text(SignInPage.uid_now,style: TextStyle(fontSize: 20),),
//              padding: EdgeInsets.fromLTRB(20.0, 12.0, 16.0, 8.0),
//            ),

//            Padding(
//              child: Text(email),
//              padding: EdgeInsets.fromLTRB(110.0, 12.0, 8.0, 8.0),
//            ),
            _buildBody(context),
            //firestore.collection('baby').document(myController.text)
//            Padding(
//              child: Text(firestore.collection('baby').document(myController.text)),
//              padding: EdgeInsets.fromLTRB(110.0, 12.0, 8.0, 8.0),
//            ),
          ],

        ),
      ),
    );
  }

}



class Record {
  final String name;
  final DocumentReference reference;
  //final String location;
  final String phone_number;
  final int budget;
  final String image;
  final String uid;


  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        name = map['name'],
        phone_number=map['phone_number'],
        budget=map['budget'],
        image=map['image'],
        uid=map['uid'];
  //    location=map['location'];



//location, phone_number, URL, restaurant_type, name, opening_hours
  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$name>";
}