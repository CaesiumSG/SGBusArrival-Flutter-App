//fuck me
//emme if you touch this im gonna wack u

import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

import 'convertreadable.dart';

getRequest(stop, lat, long, rawJson) async {
  print("getting data");
  call(website) async {
    var client = http.Client();
    var header = "1OVczLbdTU2lTTpTNXbMiA==";
    var queryRaw = await client.get(website, headers: {
      'AccountKey': header,
      "Access-Control-Allow-Origin": "*",
    });
    return convert.jsonDecode(queryRaw.body);
  }

  var url = Uri.parse(
      'http://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2?BusStopCode=${stop}&ServiceNo=');
  var requestdata = await call(url);
  var output = await resultParser(requestdata, rawJson); //returns an array
  // print(output);
  return output;
}
