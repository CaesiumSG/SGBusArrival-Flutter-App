import 'package:busarrival_utilities/pages/renderbusarrivalpage.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../database/dbHelper.dart';
import '../processes/busarrival.dart';
import '../processes/fuzzySearch.dart';
import 'favouritesPage.dart';
import 'queryPage.dart';

Icon customIcon = const Icon(Icons.search);
Widget customSearchBar = const Text('Nearest Location');

var result;
var stopDetails;
var cache;

class nearestPage extends StatefulWidget {
  var pissed;
  nearestPage({Key? key, required this.pissed}) : super(key: key);

  @override
  createState() => nearestPageState(dataList: this.pissed);
}

class nearestPageState extends State<nearestPage> {
  var rawJson = [];
  var results = []; //removed static
  var dataList = [];
  static var closestStops;
  static var queryWidget;
  nearestPageState({key, required this.dataList});

  Location location = Location();
  int _selectedIndex = 2;
  late List<Widget> _widgetSelection;
  static List<Widget> newWidget = [];
  void initState() {
    super.initState();
  }

/*  rebuildResult() async {
    _widgetSelection[0] = buildQueryList(dataList: results);
  }*/

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
              title: Text('${dataList[index]["desc"]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  )),
              subtitle: Text(
                  '${dataList[index]["stopCode"]} • ${dataList[index]["roadName"]} (${dataList[index]["distFromPhone"]}m away)',
                  style: const TextStyle(
                    color: Colors.white,
                  )),
              tileColor: Color(0xff241e30),
              onTap: () async {
                // print(index);
                var rawJson = await readJson();
                var req = await getRequest(
                    dataList[index]["stopCode"],
                    dataList[index]["stopLat"],
                    dataList[index]["stopLong"],
                    rawJson);
                // print(req);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => busArrivalRenderScreen(
                          result: req.toList(),
                          stopDetails: dataList[index],
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
