import 'dart:convert';
import 'dart:io';

import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fuzzy;
import 'package:path_provider/path_provider.dart';

import 'busarrival.dart';

var results = [];
var descArray = [];
// class Cache{
//   late String code;
//   late String road;
//   late String desc;
//   late String lat;
//   late String long;
//   Cache.fromJson(Map json) {
//     this.code = json['stopCode'];
//     this.desc = json['desc'];
//     this.road = json['roadName'];
//     this.lat = json['lat'];
//     this.long = json['long'];
//   }
// }

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/busRes.json');
}

Future readJson() async {
  try {
    final file = await _localFile;

    // Read the file
    String response = await file.readAsString();
    var rawJson = await json.decode(response);
    return rawJson;
  } catch (e) {
    // If encountering an error, return 0
    return 0;
  }
  //
  //
  // String response = await rootBundle.loadString('assets/busRes.json');
  // var rawJson = await json.decode(response);
  // return rawJson;
}

Future determineSearchTermType(String food) async {
  if (food.length < 2) return 0;
  if (food.length == 5 && (int.tryParse(food) != null)) return 3;
  if (int.tryParse(food) != null)
    return 2;
  else
    return 1;
}

var rawJson;
bool cacheFlag = false;
List<String> newDescArray = [];
var toSendBack = [];

fuzzySearch(String term) async {
  if (!cacheFlag) {
    print('cache being updated');
    rawJson = await readJson();
    for (int i = 0; i < rawJson.length; i = i + 1) {
      String temp = rawJson[i]['desc'];
      descArray.add(temp);
    }
    newDescArray = List<String>.from(descArray);
    cacheFlag = true;
  }
  print(term);
  // var jsonClass = Cache.fromJson(rawJson);
  int searchType = await determineSearchTermType(term);
  switch (searchType) {
    case 0:
      break;
    case 1:
      results = fuzzy.extractTop(
        query: term,
        choices: newDescArray,
        limit: 15,
        cutoff: 0,
      );
      var found = results[0].index;
      found = rawJson[found];
      getRequest(found["stopCode"], found["stopLat"], found["stopLong"]);
      return found;
      break;
    case 2:
      break;
    case 3:
      var found = (rawJson.toList().firstWhere((i) => i['stopCode'] == term));
      if (found == -1) return [];
      toSendBack.add(found);
      found = [];
      print(found);
      print(toSendBack);
      return (toSendBack);
    // if (isNum == 3){

  }
}
