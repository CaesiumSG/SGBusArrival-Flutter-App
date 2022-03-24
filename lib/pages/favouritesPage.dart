import 'dart:math';

import 'package:busarrival_utilities/pages/renderbusarrivalpage.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../processes/busarrival.dart';
import '../processes/fuzzySearch.dart';
import 'nearestPage.dart';
import 'queryPage.dart';

Icon customIcon = const Icon(Icons.search);
Widget customSearchBar = const Text('Favourites!');

var result;
var stopDetails;
var cache;

class favouritesPage extends StatefulWidget {
  var pissed;
  favouritesPage({Key? key, required this.pissed}) : super(key: key);

  @override
  createState() => favouritesPageState(dataList: this.pissed);
}

class favouritesPageState extends State<favouritesPage> {
  var rawJson = [];
  var results = []; //removed static
  var dataList = [];
  static var closestStops;
  static var queryWidget;
  favouritesPageState({key, required this.dataList});

  Location location = Location();
  static List<Widget> newWidget = [];

/*  rebuildResult() async {
    _widgetSelection[0] = buildQueryList(dataList: results);
  }*/

  fillBody() async {
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
    //find here is a growable list
    if (find.length == 0) return;
    //find is an array of objects
    List distArray = []; //temp array 1
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
    // print(find[0].instanceof);
    distArray.sort(); //sort the values in the temp array
    for (var newIndex = 0; newIndex < distArray.length; newIndex++) {
      //for each value in the new array
      var tempObj =
          find.where((x) => x["distFromPhone"] == distArray[newIndex]).toList();
      // tempObj = {
      //   for (var v in l) v[0]: v[1]
      // }; //match object to value in the new array in ascending order
      tempArray.add(tempObj[0]); //adds objects into another new temp array
    }
    //problem code
    // print(tempArray[0]["desc"]);
    //by this point the array of objects is sorted, so just clone the final temp array into the original array
    return tempArray;
/*    for (var aaa = 0; aaa < find.length; aaa++) {
      print(find[aaa]);
    }*/
    //end of Brian sort, time complexity is inf. anyways
  }

  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    // print(closestStops);
    return Scaffold(
      appBar: AppBar(
        title: customSearchBar,
        actions: <Widget>[],
      ),
      drawerEnableOpenDragGesture: true,
      drawer: Drawer(
        backgroundColor: Color(0xff242526),
        child: ListView(
          children: [
            ListTile(
              title: Text(
                'Search',
                style: TextStyle(color: Colors.blue),
              ),
              leading: Icon(
                Icons.directions_bus,
                color: Colors.amber[800],
              ),
              onTap: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => queryPage()));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'Favourites',
                style: TextStyle(color: Colors.blue),
              ),
              leading: Icon(
                Icons.star,
                color: Colors.amber[800],
              ),
              onTap: () async {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'Nearby',
                style: TextStyle(color: Colors.blue),
              ),
              leading: Icon(
                Icons.location_on_rounded,
                color: Colors.amber[800],
              ),
              onTap: () async {
                closestStops = await fillBody();
                print(closestStops);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            nearestPage(pissed: closestStops)));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: ListView.separated(
          // padding: const EdgeInsets.all(8),
          itemCount: dataList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Color(0xff242526)),
              ),
              title: Text(
                  '${dataList[index]["rawStopData"]["desc"]}\n${dataList[index]["rawStopData"]["stopCode"]} • ${dataList[index]["rawStopData"]["roadName"]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  )),
              subtitle: Text(
                  'Starred Buses: ${dataList[index]["starredBusesList"].map((x) => x)}',
                  style: const TextStyle(
                    color: Colors.white,
                  )),
              tileColor: Color(0xff241e30),
              onTap: () async {
                // print(index);
                var rawJson = await readJson();
                var req = await getRequest(
                    dataList[index]["rawStopData"]["stopCode"],
                    dataList[index]["rawStopData"]["stopLat"],
                    dataList[index]["rawStopData"]["stopLong"],
                    rawJson);
                // print(req);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => busArrivalRenderScreen(
                          result: req.toList(),
                          stopDetails: dataList[index]["rawStopData"],
                          cache: rawJson),
                    ));
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
      ),
    );
  }
}
