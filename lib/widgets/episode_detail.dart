import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:nintendo_dispatch/models/dispatch_feed.dart';
import 'package:nintendo_dispatch/widgets/player_widget.dart';

class EpisodeDetail extends StatelessWidget {
  Episode _episode;

  EpisodeDetail(Episode episode){
    _episode = episode;
  }

  String getHeaderImage() => "https://assets.fireside.fm/file/fireside-images/podcasts/images/b/bd6e0af5-b1d6-4783-9506-d534cfbae69e/episodes/${_episode.id.substring(0,1)}/${_episode.id}/header.jpg";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Episode Details"),
      ),
      body: SingleChildScrollView(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 20,
          children: [ 
            FadeInImage.assetNetwork(
              placeholder: "assets/placeholder.jpg",
              image:getHeaderImage()),
            Center(child: Text(_episode.title,
              textAlign: TextAlign.center, textScaleFactor: 1.6)),
            Text(_episode.summary,
              textAlign: TextAlign.center),
            PlayerWidget(url: _episode.attachments[0]?.url)
          ],
        ),
      )
    );
  }
}