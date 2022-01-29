//fuck me
//emme if you touch this im gonna wack u

import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

getRequest(stop, lat, long) async {
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
  print(url);

  var requestdata = await call(url);
  // print(requestdata);
  var grabgrab = requestdata["services"];
  if (!grabgrab) return [];
  for (var a = 0; a < grabgrab.length; a++) {}
}
