import 'dart:core';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

//assume we already have some sort of a search feature
//also assume that we already have some sort of a result that we want to query for

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
    dispVar = Colors.black;
  }
  // return Icon(
  //   Icons.airline_seat_recline_normal_rounded,
  //   color: dispVar,
  //   size: 24,
  // );
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

// parseBusTypeOperator(dispVar, busCompany) async {
//   if (dispVar == "SD") dispVar = "normal";
//   if (dispVar == "DD") dispVar = "DoubleDeckerbus";
//   if (dispVar == "BD") dispVar = "ArticulatedBus";
//   print('assets/graphics/Bus Icons/$busCompany/Icon-$busCompany-$dispVar');
//   return Image(
//       image: AssetImage(
//           'assets/graphics/Bus Icons/$busCompany/Icon-$busCompany-$dispVar'));
// }

typeReadable(dispVar) async {
  if (dispVar == "SD") return "Single";
  if (dispVar == "DD") return "Double";
  if (dispVar == "BD")
    return "Bendy";
  else
    return "-";
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
      dispVar = '$dispVar Minutes';
  }
  if (dispVar.isEmpty) dispVar = "-";
  return Text(dispVar,
      style: TextStyle(
        color: await loadReadable(space),
        fontSize: 10,
      ));
}

// busCompanyReadable(operator) async {
//   if (operator == "SMRT")
//     return "<:SMRT:838048960752254978>";
//   else if (operator == "SBST")
//     return "<:SBS:838048961045856306>";
//   else if (operator == "GAS")
//     return "<:GAS:838048960937197578>";
//   else if (operator == "TTS")
//     return "<:TTS:838048960932741201>";
//   else
//     return "<:singledeckltasvg:793042118465159201>";
// }

findStopData(cache, code) async {
  return await (cache.toList().firstWhere((i) => i['stopCode'] == code));
}

resultParser(apiResponse, cache) async {
  var pushed = [];
  // var fetchedData = await apiResponse
  //     .toList()['Services']
  //     .firstWhere((x) => x['serviceNo'] == busNum);
  // if (!fetchedData) return null;
  for (int x = 0; x < apiResponse['Services'].length; x++) {
    // print('$x of $')
    var fetchedData = await apiResponse['Services'][x];
    // print(fetchedData);
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
      ["bus_Number"]: apiResponse['Services'][x]['ServiceNo'],
      ["heading_From"]: originData,
      ["heading_To"]: destinationData,
      ["first_Arrival"]: firstTime,
      ["first_isAccessable"]: firstFeature,
      ["first_busType"]: firstType,
      ["second_Arrival"]: secondTime,
      ["second_isAccessable"]: secondFeature,
      ["second_busType"]: secondType,
      ["third_Arrival"]: thirdTime,
      ["third_isAccessable"]: thirdFeature,
      ["third_busType"]: thirdType,
    };
    //
    // pushed.add({
    //   originData,
    //   destinationData,
    //   firstTime,
    //   firstFeature,
    //   firstType,
    //   secondTime,
    //   secondFeature,
    //   secondType,
    //   thirdTime,
    //   thirdFeature,
    //   thirdType,
    // });
    pushed.add(built);
  }

  return pushed;
}

//https://api.flutter.dev/flutter/widgets/Icon-class.html
//https://api.flutter.dev/flutter/material/Colors-class.html
