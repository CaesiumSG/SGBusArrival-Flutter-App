import 'package:busarrival_utilities/pages/renderbusarrivalpage.dart';
import 'package:flutter/material.dart';

import 'processes/background.dart';
import 'processes/busarrival.dart';
import 'processes/fuzzySearch.dart';

void main() {
  background();
  runApp(const MyApp());
}

Icon customIcon = const Icon(Icons.search);
Widget customSearchBar = const Text('busArrival Utilities');

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'busarrival Utilities';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
      theme: ThemeData(scaffoldBackgroundColor: Color(0xff030303)),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  var rawJson = [];
  var results = [];
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    Text(
      'Enter at least 2 characters!',
      style: optionStyle,
    ),
    Text(
      'Favourites',
      style: optionStyle,
    ),
    Text(
      'Statics',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void updateList(list) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: customSearchBar,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                if (customIcon.icon == Icons.search) {
                  customIcon = const Icon(Icons.cancel);
                  customSearchBar = ListTile(
                    leading: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 28,
                    ),
                    title: TextField(
                      onChanged: (smth) async {
                        results = [];
                        results = await fuzzySearch(smth);
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Codes (46331) or Descriptions (jurong) are accepted!',
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                } else {
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('busArrival Utilities');
                  //do something here idk bro im not God
                }
              });
              // do something
            },
            icon: customIcon,
          ),
          SizedBox(width: 15),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {},
          )
        ],
      ),
      body: Center(
        child: ListView.separated(
          // padding: const EdgeInsets.all(8),
          itemCount: results.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Color(0xff242526)),
              ),
              title: Text('${results[index]["desc"]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  )),
              subtitle: Text(
                  '${results[index]["stopCode"]} • ${results[index]["roadName"]}',
                  style: const TextStyle(
                    color: Colors.white,
                  )),
              tileColor: Color(0xff241e30),
              onTap: () async {
                print(index);
                var rawJson = await readJson();
                var req = await getRequest(
                    results[index]["stopCode"],
                    results[index]["stopLat"],
                    results[index]["stopLong"],
                    rawJson);
                print(req);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => busArrivalRenderScreen(
                          result: req.toList(),
                          stopDetails: results[index],
                          cache: rawJson),
                    ));
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'Bus Arrivals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favourites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Static',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        backgroundColor: const Color(0xff242526),
        unselectedItemColor: Colors.white,
      ),
    );
  }
}
