import 'package:flutter/material.dart';
import 'package:nintendo_dispatch/models/dispatch_feed.dart';
import 'package:nintendo_dispatch/widgets/player_widget.dart';

class EpisodeDetail extends StatelessWidget {
  Episode _episode;

  EpisodeDetail(Episode episode){
    _episode = episode;
  }

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
              image:_episode.getHeaderImage()),
            Center(child: Text(_episode.title,
              textAlign: TextAlign.center, textScaleFactor: 1.6)),
            Text(_episode.summary,
              textAlign: TextAlign.center),
            PlayerWidget(url: _episode.attachmentUrl)
          ],
        ),
      )
    );
  }
}