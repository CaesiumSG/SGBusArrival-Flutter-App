import 'dart:core';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

//assume we already have some sort of a search feature
//also assume that we already have some sort of a result that we want to query for

//TODO: Add elements for output

//from the search bar
var searchInput = 'jurong east';
var qt = Colors.white;

loadReadable(dispVar) async {
  if (dispVar == "SEA") {
    dispVar = Colors.green;
  } else if (dispVar == "SDA") {
    dispVar = Colors.yellow;
  } else if (dispVar == "LSD") {
    dispVar = Colors.red;
  } else {
    dispVar = Colors.black;
  }
  return dispVar;
}

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

parseEmbedColor(busCompany) async {
  if (busCompany == "SBST") {
    return HexColor("#8B008B");
  } else if (busCompany == "TTS") {
    return HexColor("#007934");
  } else if (busCompany == "SMRT") {
    return HexColor("#FF0000");
  } else if (busCompany == "GAS") {
    return HexColor("#f1c400");
  } else {
    return Colors.black;
  }
}

typeReadable(dispVar) async {
  if (dispVar == "SD") dispVar = "<:singledeckltasvg:793042118465159201>";
  if (dispVar == "DD") dispVar = "<:doubledeckltasvg:793042118074695681>";
  if (dispVar == "BD") dispVar = "<:articulatedltasvg:793042118154518569>";
  if (!dispVar) dispVar = "";

  return dispVar;
}

timeReadable(dispVar) async {
  if (dispVar) {
    DateTime arrivalInstance =
        DateTime.parse(dispVar); //DateTime instance for bus arrival time
    DateTime currentTimeInstance = DateTime.now();
    Duration dispVarNew = arrivalInstance.difference(currentTimeInstance);

    dispVar = ((dispVarNew.inSeconds) / 60).floor();

    if (dispVar <= 1)
      dispVar = "**ARRIVED**";
    else
      dispVar = '$dispVarNew minutes';
  }
  if (!dispVar) dispVar = "Data Unavailable";
  return dispVar;
}

busCompanyReadable(operator) async {
  if (operator == "SMRT")
    return "<:SMRT:838048960752254978>";
  else if (operator == "SBST")
    return "<:SBS:838048961045856306>";
  else if (operator == "GAS")
    return "<:GAS:838048960937197578>";
  else if (operator == "TTS")
    return "<:TTS:838048960932741201>";
  else
    return "<:singledeckltasvg:793042118465159201>";
}

findStopData(cache, code) async {
  return await (cache.toList().firstWhere((i) => i['stopCode'] == code));
}

resultParser(apiResponse, cache, busNum) async {
  var fetchedData = await apiResponse
      .toList()['Services']
      .firstWhere((x) => x['serviceNo'] == busNum);
  if (!fetchedData) return null;
  var fieldTitleData = 'Bus: ${fetchedData.ServiceNo}';
  var operatorData = await busCompanyReadable(fetchedData.Operator);
  var originData = await findStopData(cache, fetchedData.NextBus.OriginCode);
  var destinationData =
      await findStopData(cache, fetchedData.NextBus.DestinationCode);
  var firstTime = await timeReadable(fetchedData.NextBus.EstimatedArrival);
  var firstLoad = await loadReadable(fetchedData.NextBus.Load);
  var firstFeature = await featureReadable(fetchedData.NextBus.Feature);
  var firstType = await typeReadable(fetchedData.NextBus.Type);
  var secondTime = await timeReadable(fetchedData.NextBus2.EstimatedArrival);
  var secondLoad = await loadReadable(fetchedData.NextBus2.Load);
  var secondFeature = await featureReadable(fetchedData.NextBus2.Feature);
  var secondType = await typeReadable(fetchedData.NextBus2.Type);
  var thirdTime = await timeReadable(fetchedData.NextBus3.EstimatedArrival);
  var thirdLoad = await loadReadable(fetchedData.NextBus3.Load);
  var thirdFeature = await featureReadable(fetchedData.NextBus3.Feature);
  var thirdType = await typeReadable(fetchedData.NextBus3.Type);
  return {
    fetchedData,
    fieldTitleData,
    operatorData,
    originData,
    destinationData,
    firstTime,
    firstLoad,
    firstFeature,
    firstType,
    secondTime,
    secondLoad,
    secondFeature,
    secondType,
    thirdTime,
    thirdLoad,
    thirdFeature,
    thirdType,
  };
}

//https://api.flutter.dev/flutter/widgets/Icon-class.html
//https://api.flutter.dev/flutter/material/Colors-class.html
