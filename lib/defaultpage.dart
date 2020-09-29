// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class ChangeThisClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Flutter'),
          backgroundColor: Colors.lightBlueAccent,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                semanticLabel: 'search',
              ),
              onPressed: () => Navigator.pop(context)
          ),
        ),
        body: Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}