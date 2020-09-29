// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class Filter {
  bool check;
  String name;

  Filter({@required this.check,@required this.name});  // required 가 파라미터 값을 ht 로 넣는다는 뜻인듯?

}

class SearchPage extends StatefulWidget {
//  static  Set<Filter> _chosenFilters = Set<Filter>(); // 체크된 항목들
//  static Set<Filter> getFilters(){
//    return _chosenFilters;
//  }
  static final chosen = <String>["korean", "western", "japanese", "chinese","fastfood","asian"];   // 체크된 항목들
  static final _suggestions = <Filter>[];    // 모든 항목들
  static  int radius = 5000;
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static bool flag = false;
//  static  Set<Filter> _chosenFilters = Set<Filter>(); // 체크된 항목들
  TextEditingController radiusControl;

  Widget _buildSuggestions() {
    return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16.0),
        itemCount: SearchPage._suggestions.length,
        itemBuilder: /*1*/ (context, index) {

          return _buildRow(SearchPage._suggestions[index]);
        });
  }

  Widget _buildRow(Filter pair) {
    return Container(
        width: 100,
        height: 30,
        child: ListTile(
            title: Padding(
                padding: EdgeInsets.fromLTRB(60.0, 0.0, 10.0, 0.0),
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      value: pair.check  ,
                      onChanged: (bool value) {
                        setState(() {
                          pair.check = !(pair.check);
                          if(pair.check)
                            SearchPage.chosen.add(pair.name);
                          else
                            SearchPage.chosen.remove(pair.name);

                          print(value);
                        });

                      },
                    ),
                    Text(
                        pair.name
                    ),
                  ],
                )

            ),

            onTap: () {      // Add 9 lines from here...

            })
    );

  }

  void init(){
    final arr = <String>["korean", "western", "japanese", "chinese","fastfood","asian"];
    for(int i=0;i<arr.length;i++) {
      print("ssss");
      for (int k = 0; k < SearchPage._suggestions.length; k++) {    // init 함수가 다시 호출되면 필터 목록에 계속 리스트가 추가되어서 방지하려고 해놓음(야매)
        if (SearchPage._suggestions[k].name == arr[i])
          return;
      }
      bool bb = false;
      if(SearchPage.chosen.contains(arr[i]))
        bb = true;
      Filter tmp = Filter(check: bb, name: arr[i]);
      SearchPage._suggestions.add(tmp);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    radiusControl = TextEditingController();
    init();

//      SearchPage.chosen.add(arr[i]);

    print(SearchPage.chosen.length);
    print('kkk');

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text('Search')
      ),
      body:  ListView(
        children: [
          ExpansionPanelList(
            animationDuration: Duration(seconds: 1),
            children: [
              ExpansionPanel(

                  headerBuilder: (BuildContext context, bool isExpanded){
                    return Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Filter",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                          Text("식당 유형",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                        ],
                      ),
                    );
                  },
                  body: _buildSuggestions(),
                  isExpanded: flag == true
              ),
            ],
            expansionCallback: (int index, bool status){
              setState((){
                flag = !flag;
              });
            },
          ),
          Divider(height: 1.0, color: Colors.black),
          SizedBox(height: 20,),
//          dateSection,
          Row(
            children: <Widget>[
              Padding(
                child: Text('반경 설정: ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              ),
              Container(
                width: 100,
                child: TextField(
                  controller: radiusControl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'radius',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      )),
                ),
              ),
              Padding(
                child: Text('m'),
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              ),
              Padding(
                child: Text('( 현재: '+SearchPage.radius.toString()+' m )'),
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              ),
            ],
          ),
          SizedBox(height: 20,),
          Padding(
            padding: EdgeInsets.fromLTRB(100.0, 10.0, 100.0, 0.0),
            child: SizedBox(
              width: 150,
              height: 50,
              child: RaisedButton(
                  color: Colors.blueAccent,
                  child: Text('Search',style: TextStyle(fontSize: 30,color: Colors.white),),
                  onPressed:  () {
                    SearchPage.radius = int.parse(radiusControl.text);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapHome()),
                    );
                  }
              ),
            )
          )

        ],
      ),
    );
  }
}

// TODO: Add AccentColorOverride (103)
