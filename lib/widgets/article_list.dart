import 'package:flutter/material.dart';
import 'package:nintendo_dispatch/models/articles.dart';
import 'package:nintendo_dispatch/models/dispatch.dart';
import 'package:provider/provider.dart';

import 'article_detail.dart';

class ArticleList extends StatelessWidget {
  const ArticleList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DispatchModel>(builder: (context, dispatchModel, child) {
      return Container(
        color: Theme.of(context).backgroundColor,
        child: ListView.builder(
          itemCount: dispatchModel.articleCount,
          padding: const EdgeInsets.all(12.0),
          itemBuilder: (context, i) {
            return _buildArticleRow(dispatchModel.articles[i], context);
          }
        )
      );
    });
  }

  Widget _buildArticleRow(Article article, BuildContext context) {
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