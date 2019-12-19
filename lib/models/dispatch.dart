
import 'package:flutter/foundation.dart';
import 'package:nintendo_dispatch/models/dispatch_feed.dart';

class DispatchModel extends ChangeNotifier {

  final List<Episode> _episodes;
  final List<String> _playedEpisodeIds;

  DispatchModel()
    : _episodes = [],
      _playedEpisodeIds = [];

  List<Episode> get playedEpisodes => _playedEpisodeIds.map((id) => 
    _episodes.singleWhere((x) => x.id == id)).toList();

  List<Episode> get episodes => _episodes;

  int get episodesCount => _episodes?.length;

  void addEpisodes(List<Episode> episodes) {
    if (_episodes.length > 0) {
      _episodes.clear();
    }
    
    _episodes.addAll(episodes);
    notifyListeners();
  }

  

}