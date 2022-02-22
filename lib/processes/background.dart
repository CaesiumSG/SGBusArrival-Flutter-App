import 'dart:convert' as convert;
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/busRes.json');
}

background() async {
  var arrayList = [];
  call(website) async {
    var client = http.Client();
    var header = "1OVczLbdTU2lTTpTNXbMiA==";
    var queryRaw = await client.get(website, headers: {
      'AccountKey': header,
      "Access-Control-Allow-Origin": "*",
    });
    return convert.jsonDecode(queryRaw.body);
  }

  print('requesting data...');

  for (int number = 0; number < 5501; number = number + 500) {
    // print(number);
    var handler = 'http://datamall2.mytransport.sg/ltaodataservice/BusStops?' +
        '\$' +
        'skip=${number}';
    //\$skip=${number}'
    print(handler);
    var requestLink = await Uri.parse(handler);
    var requestdata = await call(requestLink);
    for (int i = 0; i < requestdata['value'].length; i++) {
      var builder = {
        'desc': requestdata["value"][i]["Description"],
        'roadName': requestdata["value"][i]["RoadName"],
        'stopCode': requestdata["value"][i]["BusStopCode"],
        'stopLat': requestdata["value"][i]["Latitude"],
        'stopLong': requestdata["value"][i]["Longitude"]
      };
      /*print(builder);*/
      arrayList.add(builder);
    }
  }
  // const filename = 'assets/busRes.json';
  // await File(filename).writeAsString(convert.jsonEncode(arrayList));
  final file = await _localFile;

  // Write the file
  try {
    await file.writeAsString(convert.jsonEncode(arrayList));
    return print("operation suceeded without any errors");
  } catch (e) {
    print('$e');
  }
}
