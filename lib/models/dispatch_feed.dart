// To parse this JSON data, do
//
//     final episode = episodeFromJson(jsonString);

import 'dart:convert';

List<Episode> episodeFromJson(String str) => List<Episode>.from(json.decode(str).map((x) => Episode.fromJson(x)));

String episodeToJson(List<Episode> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Episode {
    String id;
    DateTime publishedDate;
    String title;
    String url;
    String content;
    String summary;
    String attachmentUrl;
    int sizeInBytes;
    int durationInSeconds;
    PartitionKey partitionKey;
    String rowKey;
    DateTime timestamp;
    ETag eTag;

    Episode({
        this.id,
        this.publishedDate,
        this.title,
        this.url,
        this.content,
        this.summary,
        this.attachmentUrl,
        this.sizeInBytes,
        this.durationInSeconds,
        this.partitionKey,
        this.rowKey,
        this.timestamp,
        this.eTag,
    });

    String getHeaderImage() => "https://assets.fireside.fm/file/fireside-images/podcasts/images/b/bd6e0af5-b1d6-4783-9506-d534cfbae69e/episodes/${id.substring(0,1)}/$id/header.jpg";

    factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        id: json["id"],
        publishedDate: DateTime.parse(json["publishedDate"]),
        title: json["title"] == null ? null : json["title"],
        url: json["url"] == null ? null : json["url"],
        content: json["content"] == null ? null : json["content"],
        summary: json["summary"] == null ? null : json["summary"],
        attachmentUrl: json["attachmentUrl"] == null ? null : json["attachmentUrl"],
        sizeInBytes: json["sizeInBytes"],
        durationInSeconds: json["durationInSeconds"],
        partitionKey: partitionKeyValues.map[json["partitionKey"]],
        rowKey: json["rowKey"],
        timestamp: DateTime.parse(json["timestamp"]),
        eTag: eTagValues.map[json["eTag"]],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "publishedDate": publishedDate.toIso8601String(),
        "title": title == null ? null : title,
        "url": url == null ? null : url,
        "content": content == null ? null : content,
        "summary": summary == null ? null : summary,
        "attachmentUrl": attachmentUrl == null ? null : attachmentUrl,
        "sizeInBytes": sizeInBytes,
        "durationInSeconds": durationInSeconds,
        "partitionKey": partitionKeyValues.reverse[partitionKey],
        "rowKey": rowKey,
        "timestamp": timestamp.toIso8601String(),
        "eTag": eTagValues.reverse[eTag],
    };
}

enum ETag { W_DATETIME_20200109_T20_3_A51_3_A28_5542874_Z, W_DATETIME_20200109_T20_3_A51_3_A28_8803651_Z }

final eTagValues = EnumValues({
    "W/\"datetime'2020-01-09T20%3A51%3A28.5542874Z'\"": ETag.W_DATETIME_20200109_T20_3_A51_3_A28_5542874_Z,
    "W/\"datetime'2020-01-09T20%3A51%3A28.8803651Z'\"": ETag.W_DATETIME_20200109_T20_3_A51_3_A28_8803651_Z
});

enum PartitionKey { CURRENT_LATEST, DEFAULT }

final partitionKeyValues = EnumValues({
    "CurrentLatest": PartitionKey.CURRENT_LATEST,
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
