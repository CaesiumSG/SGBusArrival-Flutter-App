import 'dart:core';

import 'package:flutter/material.dart';

//TODO: Add elements for output

//from the search bar
var searchInput = 'jurong east';
var qt = Colors.white;

featureReadable(dispVar) async {
  if (dispVar == "WAB") {
    dispVar = const Icon(
      Icons.accessible_rounded,
      color: Colors.black,
      size: 24,
    );
  } else {
    dispVar = const Icon(
      Icons.not_accessible_rounded,
      color: Colors.black,
      size: 24,
    );
  }
  return dispVar;
}

loadReadable(dispVar) async {
  if (dispVar == "SEA") {
    dispVar = Colors.green;
  } else if (dispVar == "SDA") {
    dispVar = Colors.yellow;
  } else if (dispVar == "LSD") {
    dispVar = Colors.red;
  } else {
    dispVar = Colors.white;
  }
  return dispVar;
}

typeReadable(dispVar) async {
  var holder;
  if (dispVar == "SD")
    holder = "Single";
  else if (dispVar == "DD")
    holder = "Double";
  else if (dispVar == "BD")
    holder = "Bendy";
  else
    holder = "-";
  return Text(holder,
      style: TextStyle(
        color: Colors.white,
        fontSize: 15,
      ));
}

timeReadable(dispVar, space) async {
  if (!dispVar.isEmpty) {
    DateTime arrivalInstance =
        DateTime.parse(dispVar); //DateTime instance for bus arrival time
    DateTime currentTimeInstance = DateTime.now();
    Duration dispVarNew = arrivalInstance.difference(currentTimeInstance);
    // print(dispVarNew.inSeconds);
    dispVar = ((dispVarNew.inSeconds) / 60).floor();
    if (dispVar <= 1)
      dispVar = "ARR";
    else
      dispVar = '$dispVar';
  }
  if (dispVar.isEmpty) dispVar = "-";
  return Text(dispVar,
      style: TextStyle(
        color: await loadReadable(space),
        fontSize: 25,
      ));
}

findStopData(cache, code) async {
  return await (cache.toList().firstWhere((i) => i['stopCode'] == code));
}

resultParser(apiResponse, cache) async {
  var pushed = [];
  for (int x = 0; x < apiResponse['Services'].length; x++) {
    var fetchedData = await apiResponse['Services'][x];
    var originData =
        await findStopData(cache, fetchedData["NextBus"]["OriginCode"]);
    var destinationData =
        await findStopData(cache, fetchedData["NextBus"]["DestinationCode"]);
    var firstTime = await timeReadable(
        fetchedData["NextBus"]["EstimatedArrival"],
        fetchedData["NextBus"]["Load"]);
    var firstFeature = await featureReadable(fetchedData["NextBus"]["Feature"]);
    var firstType = await typeReadable(fetchedData["NextBus"]["Type"]);
    var secondTime = await timeReadable(
        fetchedData["NextBus2"]["EstimatedArrival"],
        fetchedData["NextBus2"]["Load"]);
    var secondFeature =
        await featureReadable(fetchedData["NextBus2"]["Feature"]);
    var secondType = await typeReadable(fetchedData["NextBus2"]["Type"]);
    var thirdTime = await timeReadable(
        fetchedData["NextBus3"]["EstimatedArrival"],
        fetchedData["NextBus3"]["Load"]);
    var thirdFeature =
        await featureReadable(fetchedData["NextBus3"]["Feature"]);
    var thirdType = await typeReadable(fetchedData["NextBus3"]["Type"]);

    var built = {
      "bus_Number": apiResponse['Services'][x]['ServiceNo'],
      "heading_From": originData,
      "heading_To": destinationData,
      "first_Arrival": firstTime,
      "first_isAccessable": firstFeature,
      "first_busType": firstType,
      "second_Arrival": secondTime,
      "second_isAccessable": secondFeature,
      "second_busType": secondType,
      "third_Arrival": thirdTime,
      "third_isAccessable": thirdFeature,
      "third_busType": thirdType,
    };
    pushed.add(built);
  }

  return pushed;
}

//https://api.flutter.dev/flutter/widgets/Icon-class.html
//https://api.flutter.dev/flutter/material/Colors-class.html
