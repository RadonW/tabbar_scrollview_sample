import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
        //primaryColorBrightness: Brightness.light,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  ScrollController scrollController = new ScrollController();
  final GlobalKey redKey = GlobalKey();
  final GlobalKey orangeKey = GlobalKey();
  final GlobalKey yellowKey = GlobalKey();
  final GlobalKey greenKey = GlobalKey();
  final GlobalKey indigoKey = GlobalKey();
  final GlobalKey blueKey = GlobalKey();
  final GlobalKey purpleKey = GlobalKey();
  GlobalKey targetKey;
  List<GlobalKey> keyList = [];
  List<double> heightList;
  TabController tabController;
  bool showTabBar = true;
  static const double TAB_HEIGHT = 48;
  List<String> listTitle = [
    "Red",
    "Orange",
    "Yellow",
    "Green",
    "Indigo",
    "Blue",
    "Purple"
  ];

  @override
  void initState() {
    keyList = [
      redKey,
      orangeKey,
      yellowKey,
      greenKey,
      indigoKey,
      blueKey,
      purpleKey
    ];
    heightList = List.filled(keyList.length, 0);
    targetKey = redKey;
    tabController = TabController(vsync: this, length: listTitle.length);
    scrollController.addListener(() => _onScrollChanged());
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void _onTabChanged(int index) {
    // keyList contains all GlobalKey assigned to the Containers in ScrollView
    targetKey = keyList[index];
    _gotoAnchorPoint();
  }

  Color tabBarColor = Colors.white;
  double opacity = 0.0;
  void _onScrollChanged() {
    double showTabBarOffset;
    try {
      showTabBarOffset = keyList[0].currentContext.size.height - TAB_HEIGHT;
    } catch (e) {
      showTabBarOffset = heightList[0] - TAB_HEIGHT;
    }

    if (scrollController.offset >= showTabBarOffset) {
      setState(() {
        opacity = 1;
      });
    } else {
      setState(() {
        opacity = scrollController.offset / showTabBarOffset;
        if (opacity < 0) {
          opacity = 0;
        }
      });
    }
    if (scrollController.position.userScrollDirection ==
            ScrollDirection.reverse ||
        scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
      double totalOffset = -TAB_HEIGHT;
      for (int i = 0; i < keyList.length; i++) {
        if (keyList[i].currentContext != null) {
          try {
            heightList[i] = keyList[i].currentContext.size.height;
          } catch (e) {
            // if we can not get the size, this means we can use the height saved in the heightList directly.
            // because if you scroll the list to this position, all the widget ever shown has already saved it's height in the heightList
            print("can not get size, so do not modify heightList[i]");
          }
        }
        if (scrollController.offset >= totalOffset &&
            scrollController.offset < totalOffset + heightList[i]) {
          tabController.animateTo(
            i,
            duration: Duration(milliseconds: 0),
          );
          return;
        }
        totalOffset += heightList[i];
      }
    }
  }

  void _gotoAnchorPoint() async {
    GlobalKey key = targetKey;
    if (key.currentContext != null) {
      scrollController.position
          .ensureVisible(
        key.currentContext.findRenderObject(),
        alignment: 0.0,
      )
          .then((value) {
        if (scrollController.offset - TAB_HEIGHT > 0) {
          scrollController.jumpTo(scrollController.offset - TAB_HEIGHT);
        }
      });
      return;
    }
    int nearestRenderedIndex = 0;
    bool foundIndex = false;
    for (int i = keyList.indexOf(key) - 1; i >= 0; i -= 1) {
      // find first non-null-currentContext key above target key
      if (keyList[i].currentContext != null) {
        try {
          // Only when size is get without any exception，this key can be used in ensureVisible function
          Size size = keyList[i].currentContext.size;
          print("size: $size");
          foundIndex = true;
          nearestRenderedIndex = i;
        } catch (e) {
          print("size not availabel");
        }
        break;
      }
    }
    if (!foundIndex) {
      for (int i = keyList.indexOf(key) + 1; i < keyList.length; i += 1) {
        // find first non-null-currentContext key below target key
        if (keyList[i].currentContext != null) {
          try {
            // Only when size is get without any exception，this key can be used in ensureVisible function
            Size size = keyList[i].currentContext.size;
            print("size: $size");
            foundIndex = true;
            nearestRenderedIndex = i;
          } catch (e) {
            print("size not availabel");
          }
          break;
        }
      }
    }
    int increasedOffset = nearestRenderedIndex < keyList.indexOf(key) ? 1 : -1;
    for (int i = nearestRenderedIndex;
        i >= 0 && i < keyList.length;
        i += increasedOffset) {
      if (keyList[i].currentContext == null) {
        Future.delayed(new Duration(microseconds: 10), () {
          _gotoAnchorPoint();
        });
        return;
      }
      if (keyList[i] != targetKey) {
        await scrollController.position.ensureVisible(
          keyList[i].currentContext.findRenderObject(),
          alignment: 0.0,
          curve: Curves.linear,
          alignmentPolicy: increasedOffset == 1
              ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
              : ScrollPositionAlignmentPolicy.keepVisibleAtStart,
        );
      } else {
        await scrollController.position
            .ensureVisible(
          keyList[i].currentContext.findRenderObject(),
          alignment: 0.0,
        )
            .then((value) {
          Future.delayed(new Duration(microseconds: 1000), () {
            if (scrollController.offset - TAB_HEIGHT > 0) {
              scrollController.jumpTo(scrollController.offset - TAB_HEIGHT);
            } else {}
          });
        });

        break;
      }
    }
  }

  List<Widget> _buildTabsWidget(List<String> tabList) {
    var list = List<Widget>();
    String keyValue = DateTime.now().millisecondsSinceEpoch.toString();
    for (var i = 0; i < tabList.length; i++) {
      var widget = Tab(
        text: tabList[i],
        key: Key("i$keyValue"),
      );
      list.add(widget);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.topLeft,
          overflow: Overflow.clip,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return _getListItem(index);
                          },
                          childCount: _getChildCount(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (showTabBar)
              Positioned(
                top: 0,
                width: MediaQuery.of(context).size.width,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    color: tabBarColor,
                    child: TabBar(
                      controller: tabController,
                      indicatorColor: Color(0xfffdd108),
                      labelColor: Color(0xff343a40),
                      unselectedLabelColor: Color(0xff8E9AA6),
                      unselectedLabelStyle: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                      isScrollable: true,
                      labelStyle:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      tabs: _buildTabsWidget(listTitle),
                      onTap: _onTabChanged,
                    ),
                  ),
                ),
              ),
          ],
        ),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _getListItem(int index) {
    double height = 500;
    Widget item;
    switch (index) {
      case 0:
        item = Container(
          key: redKey,
          height: height,
          color: Color(0xffFF0000),
        );
        break;
      case 1:
        item = Container(
          key: orangeKey,
          height: height,
          color: Color(0xffFF7F00),
        );
        break;
      case 2:
        item = Container(
          key: yellowKey,
          height: height,
          color: Color(0xffFFFF00),
        );
        break;
      case 3:
        item = Container(
          key: greenKey,
          height: height,
          color: Color(0xff00FF00),
        );
        break;
      case 4:
        item = Container(
          key: indigoKey,
          height: height,
          color: Color(0xff00FFFF),
        );
        break;
      case 5:
        item = Container(
          key: blueKey,
          height: height * 2,
          color: Color(0xff0000FF),
        );
        break;
      case 6:
        item = Container(
          key: purpleKey,
          height: height * 2,
          color: Color(0xff8B00FF),
        );
        break;
    }
    return item;
  }

  int _getChildCount() {
    return 7;
  }
}
