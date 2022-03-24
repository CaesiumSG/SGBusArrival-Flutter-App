import 'package:busarrival_utilities/processes/notificationService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../processes/notificationService.dart';

var stopDetails;
var displayedImage;
var zoom = 17;

class mapRenderScreen extends StatefulWidget {
  var stopDetails;
  mapRenderScreen({Key? key, required this.stopDetails}) : super(key: key);
  @override
  createState() => mapRenderState(stopDetails: stopDetails);
}

class mapRenderState extends State<mapRenderScreen> {
  var result;
  var stopDetails;
  var cache;
  mapRenderState({key, required this.stopDetails});
  NotificationService notificationService = NotificationService();

  void initState() {
    displayedImage = Image.network(
      "https://developers.onemap.sg/commonapi/staticmap/getStaticImage?layerchosen=default&lat=${stopDetails["stopLat"]}&lng=${stopDetails["stopLong"]}&zoom=${zoom}&height=256&width=512&points=[${stopDetails["stopLat"]},${stopDetails["stopLong"]},\"255,255,178\",\"S\"]",
      fit: BoxFit.fitWidth,
    );

    super.initState();
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
                Icons.zoom_out,
                color: Color(0xff242526),
              ),
              onPressed: () async {
                if (zoom == 11) {
                  Fluttertoast.showToast(
                      msg:
                          "Currently at min zoom, unable to zoom out any further",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white,
                      fontSize: 14.0);
                  return;
                }
                zoom = zoom - 1;
                setState(() {
                  displayedImage = Image.network(
                    "https://developers.onemap.sg/commonapi/staticmap/getStaticImage?layerchosen=default&lat=${stopDetails["stopLat"]}&lng=${stopDetails["stopLong"]}&zoom=${zoom}&height=256&width=512&points=[${stopDetails["stopLat"]},${stopDetails["stopLong"]},\"255,255,178\",\"S\"]",
                    fit: BoxFit.fitWidth,
                  );
                });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.zoom_in,
                color: Color(0xff242526),
              ),
              onPressed: () async {
                if (zoom == 17) {
                  Fluttertoast.showToast(
                      msg:
                          "Currently at max zoom, unable to zoom in any further",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white,
                      fontSize: 14.0);
                  return;
                }
                zoom = zoom + 1;
                setState(() {
                  displayedImage = Image.network(
                    "https://developers.onemap.sg/commonapi/staticmap/getStaticImage?layerchosen=default&lat=${stopDetails["stopLat"]}&lng=${stopDetails["stopLong"]}&zoom=${zoom}&height=256&width=512&points=[${stopDetails["stopLat"]},${stopDetails["stopLong"]},\"255,255,178\",\"S\"]",
                    fit: BoxFit.fitWidth,
                  );
                });
                //code here
              },
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: displayedImage,
        ),
      ),
      theme: ThemeData(scaffoldBackgroundColor: Color(0xff030303)),
    );
  }
}
