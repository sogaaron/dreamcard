// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class SignInPage extends StatefulWidget {
  static String uid_now = "";
  static int flag;
  static FirebaseUser uu;
  final String title = 'Registration';
  @override
  State<StatefulWidget> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Builder(builder: (BuildContext context) {
        return ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            _AnonymouslySignInSection(),
            _GoogleSignInSection(),
          ],
        );
      }),
    );
  }

  // Example code for sign out.
  void _signOut() async {
    await _auth.signOut();
  }
}

class _AnonymouslySignInSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AnonymouslySignInSectionState();
}

class _AnonymouslySignInSectionState extends State<_AnonymouslySignInSection> {
  bool _success;
  String _userID;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 80.0),
        Container(
          child:  Column(
            children: <Widget>[
              SizedBox(height: 16.0),
            ],
          ),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
        ),

//        Container(
//          child: const Text('Test sign in anonymously'),
//          padding: const EdgeInsets.all(16),
//          alignment: Alignment.center,
//        ),
//        Container(
//          padding: const EdgeInsets.symmetric(vertical: 16.0),
//          alignment: Alignment.center,
//          child: RaisedButton(
//            onPressed: () async {
//              _signInAnonymously();
//              Navigator.pushNamed(context, '/');
//            },
//            child: const Text('guest'),
//          ),
//        ),
//        Container(
//          alignment: Alignment.center,
//          padding: const EdgeInsets.symmetric(horizontal: 16),
//          child: Text(
//            _success == null
//                ? ''
//                : (_success
//                ? 'Successfully signed in, uid: ' + _userID
//                : 'Sign in failed'),
//            style: TextStyle(color: Colors.red),
//          ),
//        )
      ],
    );
  }

  void _signOut() async {
    await _auth.signOut();
  }

  // Example code of how to sign in anonymously.
  void _signInAnonymously() async {
    final FirebaseUser user = (await _auth.signInAnonymously()).user;
    assert(user != null);
    assert(user.isAnonymous);
    assert(!user.isEmailVerified);
    assert(await user.getIdToken() != null);
    if (Platform.isIOS) {
      // Anonymous auth doesn't show up as a provider on iOS
      assert(user.providerData.isEmpty);
    } else if (Platform.isAndroid) {
      // Anonymous auth does show up as a provider on Android
      assert(user.providerData.length == 1);
      assert(user.providerData[0].providerId == 'firebase');
      assert(user.providerData[0].uid != null);
      assert(user.providerData[0].displayName == null);
      assert(user.providerData[0].photoUrl == null);
      assert(user.providerData[0].email == null);
    }

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        _success = true;
        _userID = user.uid;
        print("anony:"+user.uid);
        SignInPage.uid_now = _userID;   // 로그인 아이디 지정
        SignInPage.flag = 0;
        SignInPage.uu = user;
      } else {
        _success = false;
      }
    });
  }
}

class _GoogleSignInSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GoogleSignInSectionState();
}

class _GoogleSignInSectionState extends State<_GoogleSignInSection> {
  bool _success;
  String _userID;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
//        Container(
//          child: const Text('Test sign in with Google'),
//          padding: const EdgeInsets.all(16),
//          alignment: Alignment.center,
//        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child: RaisedButton(
            onPressed: () async {
              print('cccccccccccc');

              _signInWithGoogle();
              SignInPage.uid_now = _userID;   // 로그인 아이디 지정
              Navigator.pushNamed(context, '/');

            },
            child: const Text('Google'),
          ),
        ),
//        Container(
//          child: const Text('Sign out'),
//          padding: const EdgeInsets.all(16),
//          alignment: Alignment.center,
//        ),
        Container(
          child: RaisedButton(
            child: const Text('Sign out'),
            textColor: Colors.black,
            onPressed: () async {
              final FirebaseUser user = await _auth.currentUser();
              if (user == null) {
                Scaffold.of(context).showSnackBar(const SnackBar(
                  content: Text('No one has signed in.'),
                ));
                return;
              }
              _signOut();
              final String uid = user.uid;
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(uid + ' has successfully signed out.'),
              ));
            },
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _success == null
                ? ''
                : (_success
                ? 'Successfully signed in, uid: ' + _userID
                : 'Sign in failed'),
            style: TextStyle(color: Colors.red),
          ),
        )
      ],
    );
  }

  void _signOut() async {
    await _auth.signOut();
  }

  // Example code of how to sign in with google.
  void _signInWithGoogle() async {
//    print('zzzzzzzzzzzzzzzzzzzzzzzzzzzz');

    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        _success = true;
        _userID = user.uid;
        SignInPage.uid_now = _userID;   // 로그인 아이디 지정
        print("google:"+user.uid);
        SignInPage.flag = 1;
        SignInPage.uu = user;
//        print('kkkkkkkkkkkkkkkkkkkkkkkkkkkkk');
      } else {
        _success = false;
      }
    });
  }
}