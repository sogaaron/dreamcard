// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:geoflutterfire/geoflutterfire.dart';

class Event extends StatelessWidget {
  static bool flag = false;
  static String event_name = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Event List'),
          backgroundColor: Colors.lightBlueAccent,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                semanticLabel: 'back_to_main',
              ),
              onPressed: () => Navigator.pop(context)
          ),
        ),
        body: SizedBox(
          //height: 500,
          child:  Center(
            child: StreamBuilder(
//                  initialData: Firestore.instance.collection("product").orderBy("price",descending: flag).snapshots(),
                stream: Firestore.instance.collection("restaurant").where('event', isEqualTo: 1).orderBy("name",descending: false).snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
//                    print(flag);
//                    print(Firestore.instance.collection("product").orderBy("price",descending: false).snapshots());
//                    print(snapshot.data);
                  if (!snapshot.hasData) {
                    return Text(
                      'No Data...',
                    );
                  } else {
                    return new GridView.builder(

                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot ds = snapshot.data.documents[index];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            // TODO: Adjust card heights (103)
                            child: Wrap(
                              // TODO: Center items on the card (103)
                              children: <Widget>[
                                AspectRatio(
                                  aspectRatio: 18 / 11,
                                  child:Image.network(
                                    ds["image"],
                                    // TODO: Adjust the box size (102)
                                    fit: BoxFit.fitWidth,

                                  ),
                                ),
                                SizedBox(height: 130.0),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.location_on,
                                        color: Colors.lightBlueAccent,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                          event_name = ds["name"];
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => MapHome()),
                                          );
                                      },
                                    ),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            ds["name"],
                                            style: TextStyle(color: Colors.blueGrey
                                                ,fontWeight: FontWeight.bold),

                                            maxLines: 1,
                                          ),

                                          //SizedBox(height: 8.0),
                                          Text(
                                            ds["phone_number"],
                                            maxLines: 3,
                                            style: TextStyle(color: Colors.blueGrey,
                                                fontSize: 10.0,fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          Text(
                                            ds["restaurant_type"],
                                            maxLines: 3,
                                            style: TextStyle(color: Colors.blueGrey,
                                                fontSize: 10.0,fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // TODO: Handle overflowing labels (103)
                                  ],
                                ),
                                Row(

                                  mainAxisAlignment: MainAxisAlignment.end,
//                      crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
//                          margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                                          width: 70,
                                          height: 15,
//                            color: Colors.yellow,
                                          child: FlatButton(
                                            textColor: Colors.lightBlueAccent,
                                            child: Text('more',style: TextStyle(fontSize: 12),),
                                            onPressed: () {
                                              Navigator.of(context).push(MaterialPageRoute(
                                                  builder: (BuildContext context) => MyWebView(
                                                    title: ds['name'],
                                                    selectedUrl:  ds['URL'].toString(),
                                                  )));
                                            },
                                          ),
                                        )
                                    )


                                  ],
                                )
                              ],
                            ),
                          );
                        }
                    );
                  }
                }
            ),
          ),
        ),
      ),
    );
  }
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