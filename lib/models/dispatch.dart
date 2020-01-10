
import 'package:flutter/foundation.dart';
import 'package:nintendo_dispatch/models/dispatch_feed.dart';

import 'articles.dart';

class DispatchModel extends ChangeNotifier {

  final List<Episode> _episodes;
  final List<String> _playedEpisodeIds;
  final List<Article> _articles;

  DispatchModel()
    : _episodes = [],
      _playedEpisodeIds = [],
      _articles = [];

  List<Episode> get playedEpisodes => _playedEpisodeIds.map((id) => 
    _episodes.singleWhere((x) => x.id == id)).toList();

  List<Episode> get episodes => _episodes;

  List<Article> get articles => _articles;

  int get episodesCount => _episodes?.length;

  int get articleCount => _articles?.length;

  void addEpisodes(List<Episode> episodes) {
    if (episodes.length > 0) {
      _episodes.insertAll(0, episodes);
      notifyListeners();
    }
  }

    void addArticles(List<Article> articles) {
    if (articles.length > 0) {
      _articles.insertAll(0, articles);
      notifyListeners();
    }
  }

}