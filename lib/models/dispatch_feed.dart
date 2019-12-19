// To parse this JSON data, do
//
//     final dispatchFeed = dispatchFeedFromJson(jsonString);

import 'dart:convert';

DispatchFeed dispatchFeedFromJson(String str) => DispatchFeed.fromJson(json.decode(str));

String dispatchFeedToJson(DispatchFeed data) => json.encode(data.toJson());

class DispatchFeed {
    String version;
    String title;
    String homePageUrl;
    String feedUrl;
    String description;
    Fireside fireside;
    List<Episode> items;

    DispatchFeed({
        this.version,
        this.title,
        this.homePageUrl,
        this.feedUrl,
        this.description,
        this.fireside,
        this.items,
    });

    factory DispatchFeed.fromJson(Map<String, dynamic> json) => DispatchFeed(
        version: json["version"],
        title: json["title"],
        homePageUrl: json["home_page_url"],
        feedUrl: json["feed_url"],
        description: json["description"],
        fireside: Fireside.fromJson(json["_fireside"]),
        items: List<Episode>.from(json["items"].map((x) => Episode.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "version": version,
        "title": title,
        "home_page_url": homePageUrl,
        "feed_url": feedUrl,
        "description": description,
        "_fireside": fireside.toJson(),
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
    };
}

class Fireside {
    String subtitle;
    DateTime pubdate;
    bool explicit;
    String copyright;
    String owner;
    String image;

    Fireside({
        this.subtitle,
        this.pubdate,
        this.explicit,
        this.copyright,
        this.owner,
        this.image,
    });

    factory Fireside.fromJson(Map<String, dynamic> json) => Fireside(
        subtitle: json["subtitle"],
        pubdate: DateTime.parse(json["pubdate"]),
        explicit: json["explicit"],
        copyright: json["copyright"],
        owner: json["owner"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "subtitle": subtitle,
        "pubdate": pubdate.toIso8601String(),
        "explicit": explicit,
        "copyright": copyright,
        "owner": owner,
        "image": image,
    };
}

class Episode {
    String id;
    String title;
    String url;
    String contentText;
    String contentHtml;
    String summary;
    DateTime datePublished;
    List<Attachment> attachments;

    Episode({
        this.id,
        this.title,
        this.url,
        this.contentText,
        this.contentHtml,
        this.summary,
        this.datePublished,
        this.attachments,
    });

    factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        id: json["id"],
        title: json["title"],
        url: json["url"],
        contentText: json["content_text"],
        contentHtml: json["content_html"],
        summary: json["summary"],
        datePublished: DateTime.parse(json["date_published"]),
        attachments: List<Attachment>.from(json["attachments"].map((x) => Attachment.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "url": url,
        "content_text": contentText,
        "content_html": contentHtml,
        "summary": summary,
        "date_published": datePublished.toIso8601String(),
        "attachments": List<dynamic>.from(attachments.map((x) => x.toJson())),
    };
}

class Attachment {
    String url;
    MimeType mimeType;
    int sizeInBytes;
    int durationInSeconds;

    Attachment({
        this.url,
        this.mimeType,
        this.sizeInBytes,
        this.durationInSeconds,
    });

    factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
        url: json["url"],
        mimeType: mimeTypeValues.map[json["mime_type"]],
        sizeInBytes: json["size_in_bytes"],
        durationInSeconds: json["duration_in_seconds"],
    );

    Map<String, dynamic> toJson() => {
        "url": url,
        "mime_type": mimeTypeValues.reverse[mimeType],
        "size_in_bytes": sizeInBytes,
        "duration_in_seconds": durationInSeconds,
    };
}

enum MimeType { AUDIO_MP3, AUDIO_MPEG }

final mimeTypeValues = EnumValues({
    "audio/mp3": MimeType.AUDIO_MP3,
    "audio/mpeg": MimeType.AUDIO_MPEG
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
