import 'package:flutter/material.dart';

class busArrivalRenderScreen extends StatelessWidget {
  // In the constructor, require a Todo.
  var result;
  var stopDetails;
  busArrivalRenderScreen(
      {Key? key, required this.result, required this.stopDetails})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(stopDetails["desc"]),
        centerTitle: true,
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
