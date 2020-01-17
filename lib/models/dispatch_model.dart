
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nintendo_dispatch/models/dispatch_feed.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'articles.dart';

class DispatchModel extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  GlobalKey<AnimatedListState> listKey;

  final List<Episode> _episodes = [];
  final List<String> _playedEpisodeIds = [];
  final List<Article> _articles = [];

  DispatchModel(GlobalKey<AnimatedListState> animatedListKey){
    listKey = animatedListKey;
    loadData(loadFromFile: true);
  }

  List<Episode> get playedEpisodes => _playedEpisodeIds.map((id) => 
    _episodes.singleWhere((x) => x.id == id)).toList();

  List<Episode> get episodes => _episodes;

  List<Article> get articles => _articles;

  int get episodesCount => _episodes?.length;

  int get articleCount => _articles?.length;

  void addEpisodes(List<Episode> episodes) async {
    if (episodes.length > 0) {
      _episodes.insertAll(0, episodes);
      for (var i = 0; i < episodes.length * 2; i++) {
        if (listKey.currentState != null) {
          listKey.currentState.insertItem(i);
          await Future.delayed(const Duration(milliseconds: 30));
        }
      }
      notifyListeners();
    }
  }

    void addArticles(List<Article> articles) {
    if (articles.length > 0) {
      _articles.insertAll(0, articles);
      notifyListeners();
    }
  }

  int _retries = 0;

  Future fetchPodcasts() async {
    final DateTime episodeFilter = episodesCount > 0 ?
      episodes[0].publishedDate :
      DateTime.parse("1900-01-01");
    try {
      final response = await http.get("https://dispatch-functions.azurewebsites.net/api/Podcasts/List?dateFrom=$episodeFilter");

      if (response.statusCode == 200) {
        if (response.body.length > 0) {
          final episodes = episodeFromJson(response.body);
          if (episodes.length > 0) {
            addEpisodes(episodes);
            savePodcastsToFile(episodeToJson(episodes));
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
    finally {
      _retries = 0;
    }
  }

  int _articleRetries = 0;

  Future fetchArticles() async {
    final DateTime episodeFilter = articleCount > 0 ?
      articles[0].pubDate :
      DateTime.parse("1900-01-01");
    try {
      final response = await http.get("https://dispatch-functions.azurewebsites.net/api/Articles/List?dateFrom=$episodeFilter");

      if (response.statusCode == 200) {
        if (response.body.length > 0) {
          final articles = articlesFromJson(response.body);
          if (articles.length > 0) {
            addArticles(articles);
            saveArticlesToFile(articlesToJson(articles));
          }
        }
        else
        {
          if (_articleRetries < 10) {
            _articleRetries ++;
            fetchArticles();
          }
        }
      }
    } catch (e) {
      log("Error fetching articles: $e");
    }
    finally {
      _articleRetries = 0;
    }
  }

  Future loadPodcastsFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File("$path/episodeData.json");
      final data = await file.readAsString();
      final feed = episodeFromJson(data);
      addEpisodes(feed);
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
      addArticles(feed);
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

  void loadData({bool loadFromFile = false}) async {
    isLoading = true;

    try {
      if (loadFromFile) {
        await loadPodcastsFromFile();
      }
      fetchPodcasts();

      if (loadFromFile) {
        await loadArticlesFromFile();
      }
      fetchArticles();

      if (!loadFromFile) {
        await Future.delayed(Duration(seconds: 1));
      }
    } catch (e) {
      log("Error getting initial data: $e");
    }
    finally
    {
      isLoading = false;
    }
  }
}