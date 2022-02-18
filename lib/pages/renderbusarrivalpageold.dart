import 'package:flutter/material.dart';

import '../processes/busarrival.dart';

class busArrivalRenderScreen extends StatelessWidget {
  // In the constructor, require a Todo.
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
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(stopDetails["desc"]),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: Color(0xff242526),
              ),
              onPressed: () async {
                var req = await getRequest(stopDetails["stopCode"],
                    stopDetails["stopLat"], stopDetails["stopLong"], cache);
                result = req.toList();
              },
            ),
          ],
          bottom: PreferredSize(
              child: Text(
                  '${stopDetails["stopCode"]} • ${stopDetails["roadName"]}',
                  style: const TextStyle(
                    color: Colors.white,
                  )),
              preferredSize: Size.fromHeight(-5)),
        ),
        body: ListView.separated(
          itemCount: result.length,
          itemBuilder: (context, index) {
            return ListTile(
              // visualDensity: VisualDensity.comfortable,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Color(0xff242526)),
              ),
              title: Text('${result[index]["bus_Number"]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  )),
              tileColor: Color(0xff241e30),
              onTap: () {
                //insert code here
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
      ),
      theme: ThemeData(scaffoldBackgroundColor: Color(0xff030303)),
    );
  }
}

class busArrivalWidget extends StatefulWidget {
  busArrivalWidget({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => tileListState();
}

class tileListState extends State<busArrivalWidget> {
  var result;
  var stopDetails;
  var cache;

  void _rebuild() async {
    print("hi");
    var req = await getRequest(stopDetails["stopCode"], stopDetails["stopLat"],
        stopDetails["stopLong"], cache);
    setState(() {
      result = ["1", "2", "3"].toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(stopDetails["desc"]),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: Color(0xff242526),
            ),
            onPressed:
                _rebuild, /*() async {
              print("hi");
              var req = await getRequest(stopDetails["stopCode"],
                  stopDetails["stopLat"], stopDetails["stopLong"], cache);
              setState(() {
                result = ["1", "2", "3"].toList();
              });
            },*/
          ),
        ],
        bottom: PreferredSize(
            child:
                Text('${stopDetails["stopCode"]} • ${stopDetails["roadName"]}',
                    style: const TextStyle(
                      color: Colors.white,
                    )),
            preferredSize: Size.fromHeight(-5)),
      ),
      body: ListView.separated(
        itemCount: result.length,
        itemBuilder: (context, index) {
          return ListTile(
            // visualDensity: VisualDensity.comfortable,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Color(0xff242526)),
            ),
            title: Text('${result[index]["bus_Number"]}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                )),
            tileColor: Color(0xff241e30),
            onTap: () {
              //insert code here
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}

/*class BusServiceTile extends StatelessWidget {
  final String code;
  final String service;
  final BusArrival busArrival;
  BusServiceTile({this.code, this.service, this.busArrival});

  @override
  Widget build(BuildContext context) {
    // the load can be SEA, SDA, or LSD (green, orange, red)
    Map loadColors = {
      "SEA": TransitColors.seats,
      "SDA": TransitColors.standing,
      "LSD": TransitColors.limited,
    };

    final FavoritesProvider favoritesProvider =
        Provider.of<FavoritesProvider>(context, listen: true);
    bool isFavorite = FavoritesProvider.alreadyInFavorites(code, service);
  }

  Widget _actionTemplate(
    BuildContext context,
    IconData icon,
    Color color,
    Function action,
  ) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: 18,
        ),
        decoration: BoxDecoration(
          // color: TileColors.busServiceTile(context),
          color: color,
          borderRadius: BorderRadius.circular(Values.borderRadius * 0.8),
        ),
        padding: EdgeInsets.all(Values.marginBelowTitle),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
      onTap: action,
    );
  }

}*/
/*
* Container(
        child: InkWell(
          child: Padding(
            padding: EdgeInsets.all(Values.busStopTileHorizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 2,
                  child: InkWell(
                    onTap: () => Routing.openRoute(
                        context, ServicePage(service: service)),
                    child: Text(
                      service,
                      style: Theme.of(context).textTheme.display3,
                    ),
                  ),
                ),
                Flexible(
                  flex: 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      for (var nextBus in busArrival.nextBuses)
                        Text(
                          nextBus.timeInMinutes ?? '-',
                          style: Theme.of(context).textTheme.display4.copyWith(
                              color: loadColors[nextBus.load],

                              // bold text if it has arrived
                              fontWeight: nextBus.timeInMinutes == "Arr"
                                  ? FontWeight.w900
                                  : FontWeight.w400),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
          borderRadius: BorderRadius.circular(Values.borderRadius * 0.8),
          // onTap: () => ConfirmationBottomSheets.confirmAction(context, code, service),
          onTap: () => Routing.openRoute(
            context,
            ServicePage(service: service),
          ),
        ),
        margin: EdgeInsets.only(
          left: Values.pageHorizontalPadding,
          right: Values.pageHorizontalPadding,
          bottom: Values.pageHorizontalPadding,
        ),
        decoration: BoxDecoration(
          color: TileColors.busServiceTile(context),
          borderRadius: BorderRadius.circular(Values.borderRadius * 0.8),
        ),
      ),*/
