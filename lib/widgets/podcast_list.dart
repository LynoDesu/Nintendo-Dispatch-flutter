import 'package:flutter/material.dart';
import 'package:nintendo_dispatch/models/dispatch_model.dart';
import 'package:nintendo_dispatch/models/dispatch_feed.dart';
import 'package:provider/provider.dart';

import 'episode_detail.dart';

class PodcastList extends StatelessWidget {
  const PodcastList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DispatchModel>(builder: (context, dispatchModel, child) {
      return new AnimatedList(
        key: dispatchModel.listKey,
        initialItemCount: dispatchModel.episodesCount * 2,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i, animation) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          return _buildRow(dispatchModel.episodes[index], context, dispatchModel, animation);
        }
      );
    });
  }

  Widget _buildRow(Episode episode, BuildContext context, DispatchModel dispatchModel, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: GestureDetector(
        onTap: () {Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EpisodeDetail(episode)));},
        child: ListTile(
          title: Text(
              episode.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          leading: Icon(Icons.music_video, color: Colors.redAccent),
          trailing: Icon(dispatchModel.playedEpisodes.contains(episode) ? Icons.play_circle_filled : Icons.play_circle_outline, color: Colors.teal[400]),
        ),
      ),
    );
  }
}