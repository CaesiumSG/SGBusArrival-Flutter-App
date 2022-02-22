import 'dart:math';

import 'package:busarrival_utilities/pages/renderbusarrivalpage.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'pages/buildNearestList.dart';
import 'processes/background.dart';
import 'processes/busarrival.dart';
import 'processes/fuzzySearch.dart';

void main() async {
  background();
  runApp(mainPage());
}

Icon customIcon = const Icon(Icons.search);
Widget customSearchBar = const Text('busArrival Utilities');

class mainPage extends StatelessWidget {
  const mainPage({Key? key}) : super(key: key);

  static const String _title = 'busarrival Utilities';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: homePageWidget(),
      theme: ThemeData(scaffoldBackgroundColor: Color(0xff030303)),
    );
  }
}

class homePageWidget extends StatefulWidget {
  const homePageWidget({Key? key}) : super(key: key);

  @override
  State<homePageWidget> createState() => homepageState();
}

class homepageState extends State<homePageWidget> {
  var rawJson = [];
  static var results = [];
  static var closestStops = [];

  Location location = Location();
  int _selectedIndex = 2;

  fillBody() async {
    /*if (results.length > 0) {
      return Center(
        child: ListView.separated(
          // padding: const EdgeInsets.all(8),
          itemCount: results.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Color(0xff242526)),
              ),
              title: Text('${results[index]["desc"]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  )),
              subtitle: Text(
                  '${results[index]["stopCode"]} • ${results[index]["roadName"]}',
                  style: const TextStyle(
                    color: Colors.white,
                  )),
              tileColor: Color(0xff241e30),
              onTap: () async {
                print(index);
                var rawJson = await readJson();
                var req = await getRequest(
                    results[index]["stopCode"],
                    results[index]["stopLat"],
                    results[index]["stopLong"],
                    rawJson);
                fillBody();
                print(req);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => busArrivalRenderScreen(
                          result: req.toList(),
                          stopDetails: results[index],
                          cache: rawJson),
                    ));
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
      );
    }*/
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    getDist(phoneLat, phoneLong, targetLat, targetLong) {
      var x = acos(sin(phoneLat * pi / 180) * sin(targetLat * pi / 180) +
              cos(phoneLat * pi / 180) *
                  cos(targetLat * pi / 180) *
                  (sin(phoneLong * pi / 180) * sin(targetLong * pi / 180) +
                      cos(phoneLong * pi / 180) * cos(targetLong * pi / 180))) *
          6371000;
      return x.round();
    }

    _locationData = await location.getLocation();
    var locLat = _locationData.latitude;
    var locLong = _locationData.longitude;
    print(locLat);
    print(locLong);
    var maxRad = 500;
    var theList = await readJson();
    var find = await theList
        .toList()
        .where((x) =>
            getDist(locLat, locLong, x["stopLat"], x["stopLong"]) < maxRad)
        .toList();
    if (find.length == 0) return;
    //find is an array of objects
    var distArray = []; //temp array 1
    var tempArray = []; //temp array 2
    for (var aa = 0; aa < find.length; aa++) {
      find[aa]["distFromPhone"] = getDist(
          locLat,
          locLong,
          find[aa]["stopLat"],
          find[aa][
              "stopLong"]); //adds a distancefromphone property into original array (find)
      distArray.add(getDist(
          locLat,
          locLong,
          find[aa]["stopLat"],
          find[aa][
              "stopLong"])); //adds the distancefromphone value into a new temporary array
    }
    distArray.sort(); //sort the values in the temp array
    for (var newIndex = 0; newIndex < distArray.length; newIndex++) {
      //for each value in the new array
      var tempObj = find.where((x) =>
          x["distFromPhone"] ==
          distArray[
              newIndex]); //match object to value in the new array in ascending order
      tempArray.add(tempObj); //adds objects into another new temp array
    }
    //by this point the array of objects is sorted, so just clone the final temp array into the original array
    return tempArray;
/*    for (var aaa = 0; aaa < find.length; aaa++) {
      print(find[aaa]);
    }*/
    //end of Brian sort, time complexity is inf. anyways
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white);
  static List<Widget> _widgetSelection = <Widget>[
    ListView.separated(
      // padding: const EdgeInsets.all(8),
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Color(0xff242526)),
          ),
          title: Text('${results[index]["desc"]}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
              )),
          subtitle: Text(
              '${results[index]["stopCode"]} • ${results[index]["roadName"]}',
              style: const TextStyle(
                color: Colors.white,
              )),
          tileColor: Color(0xff241e30),
          onTap: () async {
            print(index);
            var rawJson = await readJson();
            var req = await getRequest(results[index]["stopCode"],
                results[index]["stopLat"], results[index]["stopLong"], rawJson);
            // print(req);
            await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => busArrivalRenderScreen(
                      result: req.toList(),
                      stopDetails: results[index],
                      cache: rawJson),
                ));
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    ),
    buildNearestList(closestStops),
    Text(
      'Getting Started: Click the search icon on the appbar to type in a search query!',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) async {
    if (index == 1) {
      closestStops = await fillBody();
    }
    print(closestStops);
    setState(() {
      _selectedIndex = index;
    });
  }

  getNearestStops() {}

  void updateList(list) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: customSearchBar,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                if (customIcon.icon == Icons.search) {
                  customIcon = const Icon(Icons.cancel);
                  customSearchBar = ListTile(
                    leading: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 28,
                    ),
                    title: TextField(
                      onChanged: (smth) async {
                        results = await fuzzySearch(smth);
                        print(results);
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Codes (46331) or Descriptions (jurong) are accepted!',
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                } else {
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('busArrival Utilities');
                  //do something here idk bro im not God
                }
              });
              // do something
            },
            icon: customIcon,
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {},
          )
        ],
      ),
      body: Center(child: _widgetSelection.elementAt(_selectedIndex)),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus),
              label: 'Bus Arrivals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_rounded),
              label: 'Nearest Stops',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: 'Favourites',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
          backgroundColor: const Color(0xff242526),
          unselectedItemColor: Colors.white,
        ),
      ),
      //bottom nav bar here
    );
  }
}

/*
* bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0), ),
        child:BottomNavigationBar(
          //elevation: 0.0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white10,*/

/*bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'Bus Arrivals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_rounded),
            label: 'Nearest Stops',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favourites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Static',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        backgroundColor: const Color(0xff242526),
        unselectedItemColor: Colors.white,
      ),*/

class bodyWidget extends StatefulWidget {
  const bodyWidget({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class bodyWidgetState extends State<bodyWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
