import 'package:busarrival_utilities/processes/notificationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timezone/timezone.dart' as tz;

import '../database/dbHelper.dart';
import '../processes/busarrival.dart';
import '../processes/notificationService.dart';
import 'mapPage.dart';

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
  NotificationService notificationService = NotificationService();
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
              IconButton(
                icon: Icon(
                  Icons.map_sharp,
                  color: Color(0xff242526),
                ),
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            mapRenderScreen(stopDetails: stopDetails),
                      ));
                  //code here
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star_sharp,
                  color: Colors.amber[800],
                ),
                onPressed: () async {
                  for (var a = 0; a < result.length; a++) {
                    await busAppDB.instance.createStarred(
                        stopDetails["stopCode"], result[a]["bus_Number"]);
                  }

                  Fluttertoast.showToast(
                      msg: "All buses serving this stop has been starred!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white,
                      fontSize: 14.0);
                  return;
                },
              ),
            ],
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
                      const SizedBox(width: 5),
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
                      const SizedBox(width: 10),
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
                      const SizedBox(width: 10),
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
                  ),
                  tileColor: Color(0xff241e30),
                  onTap: () async {
                    // var num = result[index]["bus_Number"].data;
                    await notificationService.init();
                    if (result[index]["first_Arrival"].data == "ARR") {
                      Fluttertoast.showToast(
                          msg: "Get ready, your bus is arriving",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.grey,
                          textColor: Colors.white,
                          fontSize: 14.0);
                      return;
                    }
                    Fluttertoast.showToast(
                        msg:
                            "A notification will be sent to you in ${result[index]["first_Arrival"].data} minutes when bus ${result[index]["bus_Number"]} arrives!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.grey,
                        textColor: Colors.white,
                        fontSize: 14.0);
                    AndroidNotificationDetails androidNotificationDetails =
                        AndroidNotificationDetails(
                      '12345',
                      'Your Mom',
                      playSound: true,
                      priority: Priority.high,
                      importance: Importance.high,
                    );
                    NotificationDetails platformChannelSpecifics =
                        NotificationDetails(
                            android: androidNotificationDetails);

                    // await notificationService.flutterLocalNotificationsPlugin.show(
                    //     12345,
                    //     "Get ready, your bus is arriving!",
                    //     "Bus ${result[index]["bus_Number"]} has arrived at ${stopDetails["desc"]}",
                    //     platformChannelSpecifics,
                    //     payload: 'data');

                    var busArr = int.parse(result[index]["first_Arrival"].data);
                    await notificationService.flutterLocalNotificationsPlugin
                        .zonedSchedule(
                            12345,
                            "Get ready, your bus is arriving!",
                            "Bus ${result[index]["bus_Number"]} is arrving at ${stopDetails["desc"]}",
                            tz.TZDateTime.now(tz.local)
                                .add(Duration(minutes: busArr)),
                            platformChannelSpecifics,
                            androidAllowWhileIdle: true,
                            uiLocalNotificationDateInterpretation:
                                UILocalNotificationDateInterpretation
                                    .absoluteTime);
                  },
                  onLongPress: () async {},
                  trailing: PopupMenuButton(
                      color: Colors.blue,
                      itemBuilder: (_) => <PopupMenuItem<String>>[
                            PopupMenuItem<String>(
                                child: Text('Notify me'), value: 'notify'),
                            PopupMenuItem<String>(
                                child: Text('Star/Unstar this bus stop'),
                                value: 'star'),
                          ],
                      onSelected: (selected) async {
                        print(selected);
                        switch (selected) {
                          case "notify":
                            {
                              await notificationService.init();
                              if (result[index]["first_Arrival"].data ==
                                  "ARR") {
                                Fluttertoast.showToast(
                                    msg: "Get ready, your bus is arriving",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.grey,
                                    textColor: Colors.white,
                                    fontSize: 14.0);
                                return;
                              }
                              Fluttertoast.showToast(
                                  msg:
                                      "A notification will be sent to you in ${result[index]["first_Arrival"].data} minutes when bus ${result[index]["bus_Number"]} arrives!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.grey,
                                  textColor: Colors.white,
                                  fontSize: 14.0);
                              AndroidNotificationDetails
                                  androidNotificationDetails =
                                  AndroidNotificationDetails(
                                '12345',
                                'Your Mom',
                                playSound: true,
                                priority: Priority.high,
                                importance: Importance.high,
                              );
                              NotificationDetails platformChannelSpecifics =
                                  NotificationDetails(
                                      android: androidNotificationDetails);

                              // await notificationService.flutterLocalNotificationsPlugin.show(
                              //     12345,
                              //     "Get ready, your bus is arriving!",
                              //     "Bus ${result[index]["bus_Number"]} has arrived at ${stopDetails["desc"]}",
                              //     platformChannelSpecifics,
                              //     payload: 'data');

                              var busArr = int.parse(
                                  result[index]["first_Arrival"].data);
                              await notificationService
                                  .flutterLocalNotificationsPlugin
                                  .zonedSchedule(
                                      12345,
                                      "Get ready, your bus is arriving!",
                                      "Bus ${result[index]["bus_Number"]} is arrving at ${stopDetails["desc"]}",
                                      tz.TZDateTime.now(tz.local)
                                          .add(Duration(minutes: busArr)),
                                      platformChannelSpecifics,
                                      androidAllowWhileIdle: true,
                                      uiLocalNotificationDateInterpretation:
                                          UILocalNotificationDateInterpretation
                                              .absoluteTime);
                              break;
                            }
                          case "schedule":
                            {
                              var selectedTime = await showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  helpText:
                                      "Select a time below, every day at your selected time, the application will notify you on when your bus is arriving at your bus stop!",
                                  cancelText: "Nevermind.",
                                  confirmText: "Schedule my bus!");
                              if (selectedTime == null) return;
                              var savedString =
                                  '${selectedTime.hour}_${selectedTime.minute}';
                              print(savedString);
                              return await busAppDB.instance
                                  .addOrUpdateSchedule(stopDetails["stopCode"],
                                      result[index]["bus_Number"], savedString);
                            }
                          case "star":
                            {
                              var check = await busAppDB.instance.queryStarred(
                                  stopDetails["stopCode"],
                                  result[index]["bus_Number"]);
                              if (check.length == 0) {
                                await busAppDB.instance.createStarred(
                                    stopDetails["stopCode"],
                                    result[index]["bus_Number"]);
                                Fluttertoast.showToast(
                                    msg:
                                        "You have sucessfully starred this bus-bus stop combination! Head to the sidebar at the main menu to view them!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.grey,
                                    textColor: Colors.white,
                                    fontSize: 14.0);
                              } else {
                                await busAppDB.instance.deleteStarred(
                                    stopDetails["stopCode"],
                                    result[index]["bus_Number"]);
                                await Fluttertoast.showToast(
                                    msg:
                                        "You have removed this bus-bus stop combination!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.grey,
                                    textColor: Colors.white,
                                    fontSize: 14.0);
                              }
                              break;
                            }
                        }
                      }),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
          )),
      theme: ThemeData(scaffoldBackgroundColor: Color(0xff030303)),
    );
  }
}
