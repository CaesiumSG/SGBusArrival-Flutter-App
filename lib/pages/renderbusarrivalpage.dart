import 'package:flutter/material.dart';

import '../processes/busarrival.dart';

var result;
var stopDetails;
var cache;

class busArrivalRenderScreen extends StatefulWidget {
  var result;
  var stopDetails;
  var cache;
  busArrivalRenderScreen(
      {Key? key,
      required this.result,
      required this.stopDetails,
      required this.cache})
      : super(key: key);
  @override
  createState() => busTileState(
      result: this.result, stopDetails: this.stopDetails, cache: this.cache);
}

class busTileState extends State<busArrivalRenderScreen> {
  var result;
  var stopDetails;
  var cache;
  busTileState(
      {key,
      required this.result,
      required this.stopDetails,
      required this.cache});

  void refreshData() async {
    var req = await getRequest(stopDetails["stopCode"], stopDetails["stopLat"],
        stopDetails["stopLong"], cache);
    result = req.toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Center(
                child: Text(
              stopDetails["desc"] +
                  '\n(${stopDetails["stopCode"]} • ${stopDetails["roadName"]})',
              textAlign: TextAlign.center,
            )),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: Color(0xff242526),
                ),
                onPressed: refreshData,
              ),
            ],
            // bottom: PreferredSize(
            //     child: Text(
            //         '${stopDetails["stopCode"]} • ${stopDetails["roadName"]}',
            //         style: const TextStyle(
            //           color: Colors.white,
            //         )),
            //     preferredSize: Size.fromHeight(5)),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              var req = await getRequest(stopDetails["stopCode"],
                  stopDetails["stopLat"], stopDetails["stopLong"], cache);
              result = req.toList();
              setState(() {});
            },
            child: ListView.separated(
              itemCount: result.length,
              itemBuilder: (context, index) {
                return ListTile(
                  // visualDensity: VisualDensity.comfortable,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Color(0xff242526)),
                  ),
                  title: Row(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                              width: 66,
                              child: Text('${result[index]["bus_Number"]}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                  ))),
                        ],
                      ),
                      const SizedBox(width: 30),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                              width: 50,
                              child: Center(
                                  child: result[index]["first_Arrival"])),
                          SizedBox(
                              width: 50,
                              child: Center(
                                  child: result[index]["first_busType"])),
                        ],
                      ),
                      result[index]["first_isAccessable"],
                      const SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                              width: 50,
                              child: Center(
                                  child: result[index]["second_Arrival"])),
                          SizedBox(
                              width: 50,
                              child: Center(
                                  child: result[index]["second_busType"])),
                        ],
                      ),
                      result[index]["second_isAccessable"],
                      const SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                              width: 50,
                              child: Center(
                                  child: result[index]["third_Arrival"])),
                          SizedBox(
                              width: 50,
                              child: Center(
                                  child: result[index]["third_busType"])),
                        ],
                      ),
                      result[index]["third_isAccessable"],
                    ],
                  )
                  /*Text('${result[index]["bus_Number"]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ))*/
                  ,
                  tileColor: Color(0xff241e30),
                  onTap: () {
                    //insert code here
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
          )),
      theme: ThemeData(scaffoldBackgroundColor: Color(0xff030303)),
    );
/*    return Scaffold(
        appBar: AppBar(
          title: Text("Parking Details"),
        ),
        body: FutureBuilder<ParkingGroup>(
          future: ParkingService.getParking(),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? _buildParking(snapshot.data)
                : Center(child: CircularProgressIndicator());
          },
        ));*/
  }
}

final _parkings = [];

Widget _buildParking(parkingGroup) {
  _parkings.clear();
  _parkings.addAll(parkingGroup.groups);

  return ListView.builder(
    itemCount: _parkings.length,
    itemBuilder: (context, index) {
      return _buildRow(_parkings[index], context);
    },
  );
}

Widget _buildRow(parkingGroup, BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      // As you expect multiple lines you need a column not a row
      children: _buildRowList(parkingGroup),
    ),
  );
}

List<Widget> _buildRowList(parkingGroup) {
  List<Widget> lines = []; // this will hold Rows according to available lines
  for (var line in parkingGroup.lines) {
    List<Widget> placesForLine = []; // this will hold the places for each line
    for (var placeLine in line.places) {
      placesForLine.add(_buildPlace(placeLine));
    }
    lines.add(Row(children: placesForLine));
  }
  return lines;
}

Widget _buildPlace(place) {
  return Container(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: SizedBox(
      height: 5,
      width: 5,
      child: DecoratedBox(
          decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
      )),
    ),
  );
}
