import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:nintendo_dispatch/models/articles.dart';

class ArticleDetail extends StatelessWidget {
  Article _article;

  ArticleDetail(Article article){
    _article = article;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Article Details"),
      ),
      body: SingleChildScrollView(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 20,
          children: [ 
            FadeInImage.assetNetwork(
              placeholder: "assets/placeholder.jpg",
              image:_article.getHeaderImage()),
            Center(child: Text(_article.title,
              textAlign: TextAlign.center, textScaleFactor: 1.6)),
            HtmlWidget(_article.content, webView: true, webViewJs: false)
          ],
        ),
      )
    );
  }
}