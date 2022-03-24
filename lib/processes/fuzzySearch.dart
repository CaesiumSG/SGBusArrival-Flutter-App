import 'dart:convert';
import 'dart:io';

import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fuzzy;
import 'package:path_provider/path_provider.dart';

var results = [];
var descArray = [];

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
}

Future determineSearchTermType(String food) async {
  if (food.length < 2) return 0; //lesser than 2
  if (food.length == 5 && (int.tryParse(food) != null)) return 3; //stopcode
  if (int.tryParse(food) != null) //if search term is a number
    return 2;
  else
    return 1;
}

var rawJson;
var cacheFlag = false;
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
      // print(results);
      var querySorted = [];
      for (var resultIndex = 0; resultIndex < results.length; resultIndex++) {
        querySorted.add(rawJson[results[resultIndex].index]);
      }
      return querySorted;
    case 2:
      break;
    case 3:
      var found =
          await (rawJson.toList().firstWhere((i) => i['stopCode'] == term));
      if (found == -1) return [];
      return [found];
  }
}
