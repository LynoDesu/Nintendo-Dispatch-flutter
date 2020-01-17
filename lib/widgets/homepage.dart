import 'package:flutter/material.dart';
import 'package:nintendo_dispatch/models/dispatch_model.dart';
import 'package:nintendo_dispatch/widgets/podcast_list.dart';
import 'package:provider/provider.dart';

import 'article_list.dart';
import 'loading_indicator.dart';

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

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  final List<Tab> myTabs = <Tab>[
    Tab(text: "Podcasts", icon: Icon(Icons.music_video, color: Colors.white)),
    Tab(text: 'Articles', icon: Icon(Icons.note, color: Colors.white))
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

 @override
 void dispose() {
   WidgetsBinding.instance.removeObserver(this);
   _tabController.dispose();
   super.dispose();
 }

 void _updateModel() {
    setState(() {
      // Cause the UI to rebuild when the model changes.
    });
  }

  @override
  void didChangePlatformBrightness() {
    _updateModel();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Consumer<DispatchModel>( builder: (context, dispatchModel, child) {
          return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.refresh), onPressed: () => dispatchModel.loadData()),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: myTabs,
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
        body: Stack(
          children: buildChildren(dispatchModel)
        )
      );
    });
  }

  List<Widget> buildChildren(DispatchModel dispatchModel) {
    final children = List<Widget>();
    children.add(TabBarView(
          controller: _tabController,
          children: myTabs.map((Tab tab) {
            return getTabContent(tab);
          }).toList(),
        ));
    if (dispatchModel.isLoading) {
      children.add(LoadingIndicator());
    }

    return children;
  }

  Widget getTabContent(Tab tab) {
    switch (tab.text) {
      case "Podcasts":
        return PodcastList();
        break;
      case "Articles":
        return ArticleList();
        break;
      default:
        return null;
        break;
    }
  }
}