import 'dart:math';

import 'package:busarrival_utilities/pages/renderbusarrivalpage.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../database/dbHelper.dart';
import '../processes/busarrival.dart';
import '../processes/fuzzySearch.dart';
import 'favouritesPage.dart';
import 'nearestPage.dart';

Icon customIcon = const Icon(Icons.search);
Widget customSearchBar = const Text('busArrival Utilities');

var result;
var stopDetails;
var cache;

class queryPage extends StatefulWidget {
  queryPage({Key? key}) : super(key: key);

  @override
  createState() => queryPageState();
}

class queryPageState extends State<queryPage> {
  var rawJson = [];
  var results = []; //removed static
  static var closestStops;
  static var queryWidget;

  Location location = Location();
  int _selectedIndex = 2;
  late List<Widget> _widgetSelection;
  static List<Widget> newWidget = [];
  void initState() {
/*    _widgetSelection = [
      buildQueryList(dataList: []),
      buildNearestList(dataList: closestStops),
      Text(
        'Getting Started: Click the search icon on the appbar to type in a search query!',
        style: optionStyle,
      ),
    ];*/
    super.initState();
  }

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
    } //i am very proud of this one

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
                        // print('hi $results');
                        setState(() {});
                        // recreateQueryWidget();
                        // rebuildList();
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
              onTap: () {
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
                var rawJson = await readJson();
                var listJson = rawJson.toList();
                var starred = await busAppDB.instance
                    .readAll(); //returns a list of objects of starred locations + bus combi
                var stopListNoDuplicates = [];
                var foundData = [];

                for (var aa = 0; aa < starred.length; aa++) {
                  stopListNoDuplicates.add(starred[aa]["starredStopCode"]);
                }

                stopListNoDuplicates =
                    stopListNoDuplicates.toSet().toList(); //removes duplicates

                for (var a = 0; a < stopListNoDuplicates.length; a++) {
                  var temp = await (listJson.firstWhere((i) =>
                      i['stopCode'] ==
                      stopListNoDuplicates[a].toString())); //returns stop data
                  foundData.add(temp); //returns array of object (stop data)
                }
                var actualOutput = [];
                //now my foundData will work but i need to group buses to their found data
                for (var b = 0; b < foundData.length; b++) {
                  var objectBuilder = {
                    'stopCode': foundData[b]["stopCode"],
                    'rawStopData': foundData[b],
                    'starredBusesList': []
                  };
                  actualOutput.add(objectBuilder);
                }
                actualOutput.toList();
                //i have my array of objects for favourites data, i have stopcode and rawstopdata, now i need to fit the buses into them
                for (var c = 0; c < actualOutput.length; c++) {
                  var temp2 = starred
                      .where((x) =>
                          x["starredStopCode"].toString() ==
                          actualOutput[c]["stopCode"].toString())
                      .toList(); //returns an array
                  for (var d = 0; d < temp2.length; d++) {
                    print(temp2[d]);
                    actualOutput[c]["starredBusesList"]
                        .add(temp2[d]["starredBusNumber"]);
                  }
                }
                print(actualOutput);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          favouritesPage(pissed: actualOutput),
                    ));
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
      ),
    );
  }
}
