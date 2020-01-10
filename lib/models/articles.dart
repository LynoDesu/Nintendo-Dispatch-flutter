// To parse this JSON data, do
//
//     final articles = articlesFromJson(jsonString);

import 'dart:convert';

List<Article> articlesFromJson(String str) => List<Article>.from(json.decode(str).map((x) => Article.fromJson(x)));

String articlesToJson(List<Article> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Article {
    String title;
    String link;
    String id;
    DateTime pubDate;
    Authors authors;
    String description;
    String content;
    PartitionKey partitionKey;
    String rowKey;
    DateTime timestamp;
    ETag eTag;

    Article({
        this.title,
        this.link,
        this.id,
        this.pubDate,
        this.authors,
        this.description,
        this.content,
        this.partitionKey,
        this.rowKey,
        this.timestamp,
        this.eTag,
    });

    String getHeaderImage() => "https://assets.fireside.fm/file/fireside-images/podcasts/images/b/bd6e0af5-b1d6-4783-9506-d534cfbae69e/articles/${id.substring(0,1)}/$id/header.jpg";

    factory Article.fromJson(Map<String, dynamic> json) => Article(
        title: json["title"],
        link: json["link"],
        id: json["id"],
        pubDate: DateTime.parse(json["pubDate"]),
        authors: authorsValues.map[json["authors"]],
        description: json["description"],
        content: json["content"],
        partitionKey: partitionKeyValues.map[json["partitionKey"]],
        rowKey: json["rowKey"],
        timestamp: DateTime.parse(json["timestamp"]),
        eTag: eTagValues.map[json["eTag"]],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "link": link,
        "id": id,
        "pubDate": pubDate.toIso8601String(),
        "authors": authorsValues.reverse[authors],
        "description": description,
        "content": content,
        "partitionKey": partitionKeyValues.reverse[partitionKey],
        "rowKey": rowKey,
        "timestamp": timestamp.toIso8601String(),
        "eTag": eTagValues.reverse[eTag],
    };
}

enum Authors { SOUNDBITEFM_GMAIL_COM }

final authorsValues = EnumValues({
    "soundbitefm@gmail.com": Authors.SOUNDBITEFM_GMAIL_COM
});

enum ETag { W_DATETIME_20200110_T13_3_A55_3_A50_5877451_Z }

final eTagValues = EnumValues({
    "W/\"datetime'2020-01-10T13%3A55%3A50.5877451Z'\"": ETag.W_DATETIME_20200110_T13_3_A55_3_A50_5877451_Z
});

enum PartitionKey { DEFAULT }

final partitionKeyValues = EnumValues({
    "Default": PartitionKey.DEFAULT
});

class EnumValues<T> {
    Map<String, T> map;
    Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        if (reverseMap == null) {
            reverseMap = map.map((k, v) => new MapEntry(v, k));
        }
        return reverseMap;
    }
}
