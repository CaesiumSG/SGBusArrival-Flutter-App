import 'package:busarrival_utilities/pages/renderbusarrivalpage.dart';
import 'package:flutter/material.dart';

import '../processes/busarrival.dart';
import '../processes/fuzzySearch.dart';

class buildNearestList extends StatefulWidget {
  var dataList;
  buildNearestList({
    key,
    required this.dataList,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new nearestListState(dataList: this.dataList);
  }
}

class nearestListState extends State<buildNearestList> {
  var dataList;
  nearestListState({
    key,
    required this.dataList,
  });

  @override
  Widget build(BuildContext context) {
    print('bye ${dataList}');
    return ListView.separated(
      // padding: const EdgeInsets.all(8),
      itemCount: dataList.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Color(0xff242526)),
          ),
          title: Text('${dataList[index]["desc"]}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
              )),
          subtitle: Text(
              '${dataList[index]["stopCode"]} • ${dataList[index]["roadName"]} (${dataList[index]["distFromPhone"]}m away)',
              style: const TextStyle(
                color: Colors.white,
              )),
          tileColor: Color(0xff241e30),
          onTap: () async {
            // print(index);
            var rawJson = await readJson();
            var req = await getRequest(
                dataList[index]["stopCode"],
                dataList[index]["stopLat"],
                dataList[index]["stopLong"],
                rawJson);
            // print(req);
            await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => busArrivalRenderScreen(
                      result: req.toList(),
                      stopDetails: dataList[index],
                      cache: rawJson),
                ));
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
