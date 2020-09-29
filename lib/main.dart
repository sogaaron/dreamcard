//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:location/location.dart';

import 'restaurantlist.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'mypage.dart';
import 'signin_page.dart';
import 'event.dart';
import 'filter.dart';

void main() => runApp(MapHome());


class MapHome extends StatelessWidget {
  // #docregion build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyApp(),
    );
  }
// #enddocregion build
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
//  Completer<GoogleMapController> _controller = Completer();
  static  LatLng _center =  LatLng(36.082368, 129.398413);    // 하나로 마트
//  static LatLng _center = LatLng(pos.latitude, pos.longitude);

  final Set<Marker> _markers = {};
//  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;
  GoogleMapController _mapController;
  TextEditingController _latitudeController, _longitudeController, name_con;
  CameraPosition cameraPosition;
//  BitmapDescriptor myIcon;
  Geolocator geolocator = Geolocator();

  Position userLocation;

  Firestore _firestore = Firestore.instance;
  Geoflutterfire geo;
  Stream<List<DocumentSnapshot>> stream;
  var radius = BehaviorSubject<double>.seeded(1.0);
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
//  Position pos = Position(latitude: 36.083376,longitude: 129.396455);   // 포메인

  @override
  void initState() {
    // TODO: implement initState
//    print('iiiiiiiiiiiiiiiiiiiiiiii');
    super.initState();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    name_con = TextEditingController();

  }


  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition();
    } catch (e) {
      currentLocation = null;
//      print('eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee');
    }
    return currentLocation;
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    }
    );
  }

  void _onCameraMove(CameraPosition position) {
//    _lastMapPosition = position.target;
    print('movemoveeeeeeeeeeeeeeee');
    setState(() {
      cameraPosition = position;
      print(cameraPosition.target.latitude);
    });
//    updateMark(cameraPosition);
  }

  void _onMapCreated(GoogleMapController controller) {

      _getLocation().then((position) {  // 여기서 시간이 걸려서 현재좌표 구하려면 이 함수 안에서 할당해야함
        print('wowowow');
        print(position.latitude);
        print(position.longitude);
        userLocation = position;
//        print(userLocation.latitude);
      _center = LatLng(userLocation.latitude, userLocation.longitude);
        print('mmmmmmm');
        _mapController = controller;
        geo = Geoflutterfire();
//    GeoFirePoint center = geo.point(latitude: 36.078730, longitude: 129.392920);  // 장흥초등학교
        GeoFirePoint center = geo.point(latitude: userLocation.latitude, longitude: userLocation.longitude);  // 현재 위치

        int rad = SearchPage.radius;
        var collectionReference = _firestore.collection('restaurant');
        stream = geo.collection(collectionRef: collectionReference).within(
            center: center, radius: rad/1000, field: 'location', strictMode: true);  // 반경 조절 가능

        //start listening after map is created
        stream.listen((List<DocumentSnapshot> documentList) {
//          print('llllllllllllllllllisten');
          _updateMarkers(documentList);
        });

        CameraPosition cp = CameraPosition(target: LatLng(userLocation.latitude, userLocation.longitude));
        _onCameraMove(cp);
      });

  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
//    print("uuuuuuuuuuuuuu");
    print(documentList.length);
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint point = document.data['location']['geopoint'];
      String name = document.data['name'];
      String phone = document.data['phone_number'];
      String url = document.data['URL'];
      int like = document.data['like'];
      String type = document.data['restaurant_type'];
      _addMarker(point.latitude, point.longitude,name,phone,url,like,type);
//      print("ppppppppppppppppppppp");
      print(type);
    });
  }

  void _addMarker(double lat, double lng, String name, String phone, String url, int like, String type) {

    if(!SearchPage.chosen.contains(type))   // 체크한 타입 아니라면 마커 생성 안하도록
      return;

    double tmp = BitmapDescriptor.hueCyan;
    if(like > 0)                // favorite 체크 유무
      tmp = BitmapDescriptor.hueViolet;

    if(Event.event_name == name){       // 이벤트 지점 중 클릭한 곳
      tmp = BitmapDescriptor.hueYellow;
      _mapController.moveCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng),17));
      Event.event_name = "";
    }

    MarkerId id = MarkerId(lat.toString() + lng.toString());
    Marker _marker = Marker(

      markerId: id,
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(tmp),
      infoWindow: InfoWindow(
          title: '$name',
          snippet: '$phone',
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => MyWebView(
                  title: name,
                  selectedUrl: url,
                )));
          }),
    );
    setState(() {

      markers[id] = _marker;
    });
  }


  void eventcheck_release() {
    GeoFirePoint center = geo.point(latitude: 36.078730, longitude: 129.392920);  // 장흥초등학교
    int rad = SearchPage.radius;
    var collectionReference = _firestore.collection('restaurant');
    stream = geo.collection(collectionRef: collectionReference).within(
        center: center, radius: rad/1000, field: 'location', strictMode: true);  // 반경 조절 가능

    setState(() {
      stream.listen((List<DocumentSnapshot> documentList) {
//        print('llllllllllllllllllisten');
        _updateMarkers(documentList);
      });
    });
  }

  void _addPoint(double lat, double lng, String name) {
    GeoFirePoint geoFirePoint = geo.point(latitude: lat, longitude: lng);
    _firestore
        .collection('restaurant').document(name)
        .setData({'name': 'random name', 'location': geoFirePoint.data}).then((_) {
      print('added ${geoFirePoint.hash} successfully');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions:<Widget>[
          IconButton(
            icon: Icon(
              Icons.sort,
              semanticLabel: 'fliter',
            ),
            onPressed: () => Navigator.push(
              context,MaterialPageRoute(builder: (context)=>SearchPage()),
            ),
          ),
        ],
        title: Text('DreamCard'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: EdgeInsets.fromLTRB(20, 120, 0, 0),
              child:
              //child: new CircleAvatar()),color: Colors.tealAccent,
              Text('Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
              ),
            ),
            ListTile(
              title: Text('Home'),
              leading: Icon(Icons.home,
                  color : Colors.lightBlueAccent),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
                title: Text('Restaurant list'),
                leading: Icon(Icons.location_city,
                    color : Colors.lightBlueAccent),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RestaurantList()),
                )
            ),
            ListTile(
                title: Text('Event'),
                leading: Icon(Icons.event_available,
                    color : Colors.lightBlueAccent),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Event()),
                )
            ),
            ListTile(
                title: Text('Login'),
                leading: Icon(Icons.assignment_ind ,
                    color : Colors.lightBlueAccent),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                )
            ),
            ListTile(
                title: Text('MyPage'),
                leading: Icon(Icons.person ,
                    color : Colors.lightBlueAccent),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                )
            ),

          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 15.0,
            ),
            mapType: _currentMapType,
            markers: Set<Marker>.of(markers.values),
            onCameraMove: _onCameraMove,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: _onMapTypeButtonPressed,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.lightBlueAccent,
                    child: const Icon(Icons.map, size: 36.0),
                  ),
                  SizedBox(height: 16.0),
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: (){
                      eventcheck_release();
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.lightBlueAccent,
                    child: const Icon(Icons.autorenew, size: 36.0),
                  ),
                ],
              ),
            ),
          ),
        ],
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