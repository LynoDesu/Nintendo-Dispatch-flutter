
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nintendo_dispatch/models/articles.dart';
import 'package:nintendo_dispatch/models/dispatch.dart';
import 'package:http/http.dart' as http;
import 'package:nintendo_dispatch/models/dispatch_feed.dart';
import 'package:nintendo_dispatch/widgets/article_detail.dart';
import 'package:path_provider/path_provider.dart';

import 'widgets/episode_detail.dart';

void main() => runApp(MyApp());

DispatchModel _dispatchModel;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Dispatch Podcast',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.red,
          backgroundColor: Colors.grey.shade200
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.red,
        ),
        debugShowCheckedModeBanner: false,
        home: MyHomePage(title: 'Dispatch Podcast', model: DispatchModel()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.model}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final DispatchModel model;

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
    _dispatchModel = widget.model;
    
    _dispatchModel.addListener(_updateModel);
    getInitialData();
  }

 @override
 void dispose() {
   WidgetsBinding.instance.removeObserver(this);
   _tabController.dispose();
   _dispatchModel.removeListener(_updateModel);
   _dispatchModel.dispose();
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
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: () => fetchPodcasts() )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      body: TabBarView(
        controller: _tabController,
        children: myTabs.map((Tab tab) {
          return getTabContent(tab);
        }).toList(),
      ),
    );
  }

  int _retries = 0;

  Future fetchPodcasts() async {
    final DateTime episodeFilter = _dispatchModel.episodesCount > 0 ?
      _dispatchModel.episodes[0].publishedDate :
      DateTime.parse("1900-01-01");
    try {
      final response = await http.get("https://dispatch-functions.azurewebsites.net/api/Podcasts/List?dateFrom=$episodeFilter");

      if (response.statusCode == 200) {
        if (response.body.length > 0) {
          final episodes = episodeFromJson(response.body);
          if (episodes.length > 0) {
            _dispatchModel.addEpisodes(episodes);
            savePodcastsToFile(episodeToJson(_dispatchModel.episodes));
          }
        }
        else
        {
          if (_retries < 10) {
            _retries ++;
            fetchPodcasts();
          }
        }
      }
    } catch (e) {
      log("Error fetching podcasts: $e");
    }
  }

  Future fetchArticles() async {
    final DateTime episodeFilter = _dispatchModel.articleCount > 0 ?
      _dispatchModel.articles[0].pubDate :
      DateTime.parse("1900-01-01");
    try {
      final response = await http.get("https://dispatch-functions.azurewebsites.net/api/Articles/List?dateFrom=$episodeFilter");

      if (response.statusCode == 200) {
        if (response.body.length > 0) {
          final articles = articlesFromJson(response.body);
          if (articles.length > 0) {
            _dispatchModel.addArticles(articles);
            saveArticlesToFile(articlesToJson(_dispatchModel.articles));
          }
        }
        else
        {
          if (_retries < 10) {
            _retries ++;
            fetchArticles();
          }
        }
      }
    } catch (e) {
      log("Error fetching articles: $e");
    }
    
  }

  void getInitialData() async {
    await loadPodcastsFromFile();
    fetchPodcasts();

    await loadArticlesFromFile();
    fetchArticles();
  }

  Future loadPodcastsFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File("$path/episodeData.json");
      final data = await file.readAsString();
      final feed = episodeFromJson(data);
      _dispatchModel.addEpisodes(feed);
    } catch (e) {
      log("Unable to load podcasts from file: $e");
    }
  }

  Future loadArticlesFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File("$path/articleData.json");
      final data = await file.readAsString();
      final feed = articlesFromJson(data);
      _dispatchModel.addArticles(feed);
    } catch (e) {
      log("Unable to load articles from file: $e");
    }
  }

  Future savePodcastsToFile(String json) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    var file = File("$path/episodeData.json");
    await file.writeAsString(json);
  }

  Future saveArticlesToFile(String json) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    var file = File("$path/articleData.json");
    await file.writeAsString(json);
  }

  Widget getTabContent(Tab tab) {
    Widget tabWidget;
    switch (tab.text) {
      case "Podcasts":
        var children = <Widget>[];
        if (_dispatchModel.episodesCount > 0) {
          children.add(buildPodcasts());
        }
        else
        {
          children.add(Center(child: CircularProgressIndicator()));
        }
        tabWidget = Stack(
          children: children
        );
        break;
      case "Articles":
        tabWidget = buildArticles();
        break;
      case "Reviews":
        tabWidget = Center(child: Text("Coming Soon!", textScaleFactor: 2));
        break;
    }

    return tabWidget;
  }

  Widget buildPodcasts() {
    return new ListView.builder(
      itemCount: _dispatchModel.episodesCount * 2,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();

        final index = i ~/ 2;
        return _buildRow(_dispatchModel.episodes[index]);
      }
    );
  }

  Widget _buildRow(Episode episode) {
    return GestureDetector(
      onTap: () {Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EpisodeDetail(episode)));},
      child: ListTile(
        title: Text(
            episode.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        leading: Icon(Icons.music_video, color: Colors.redAccent),
        trailing: Icon(_dispatchModel.playedEpisodes.contains(episode) ? Icons.play_circle_filled : Icons.play_circle_outline, color: Colors.teal[400]),
      ),
    );
  }

  Widget buildArticles() {
    return new Container(
      color: Theme.of(context).backgroundColor,
      child: ListView.builder(
        itemCount: _dispatchModel.articleCount,
        padding: const EdgeInsets.all(12.0),
        itemBuilder: (context, i) {
          return _buildArticleRow(_dispatchModel.articles[i]);
        }
      )
    );
  }

  Widget _buildArticleRow(Article article) {
    return GestureDetector(
      onTap: () {Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ArticleDetail(article)));},
      child: Card(
        margin: EdgeInsets.fromLTRB(3, 2, 3, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.gamepad, color: Colors.redAccent),
              title: Text(article.title,
                style: TextStyle(fontWeight: FontWeight.bold)
              )
            ),
            FadeInImage.assetNetwork(
              placeholder: "assets/placeholder.jpg",
              image:article.getHeaderImage(),
              height: 125,
              width: 1000,
              fit: BoxFit.cover,
              alignment: Alignment.center
            ),
            Container(
              margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Text(article.description),
            )
          ]
        ),
      )
    );
  }
}
