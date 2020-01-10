namespace NintendoDispatch.Models
{
    using System;
    using System.Collections.Generic;

    using System.Globalization;
    using Newtonsoft.Json;
    using Newtonsoft.Json.Converters;

    public partial class DispatchFeed
    {
        [JsonProperty("version")]
        public Uri Version { get; set; }

        [JsonProperty("title")]
        public string Title { get; set; }

        [JsonProperty("home_page_url")]
        public Uri HomePageUrl { get; set; }

        [JsonProperty("feed_url")]
        public Uri FeedUrl { get; set; }

        [JsonProperty("description")]
        public string Description { get; set; }

        [JsonProperty("_fireside")]
        public Fireside Fireside { get; set; }

        [JsonProperty("items")]
        public EpisodeItem[] Items { get; set; }
    }

    public partial class Fireside
    {
        [JsonProperty("subtitle")]
        public string Subtitle { get; set; }

        [JsonProperty("pubdate")]
        public DateTime Pubdate { get; set; }

        [JsonProperty("explicit")]
        public bool Explicit { get; set; }

        [JsonProperty("copyright")]
        public string Copyright { get; set; }

        [JsonProperty("owner")]
        public string Owner { get; set; }

        [JsonProperty("image")]
        public Uri Image { get; set; }
    }

    public partial class EpisodeItem
    {
        [JsonProperty("id")]
        public System.Guid Id { get; set; }

        [JsonProperty("title")]
        public string Title { get; set; }

        [JsonProperty("url")]
        public Uri Url { get; set; }

        [JsonProperty("content_text")]
        public string ContentText { get; set; }

        [JsonProperty("content_html")]
        public string ContentHtml { get; set; }

        [JsonProperty("summary")]
        public string Summary { get; set; }

        [JsonProperty("date_published")]
        public DateTime DatePublished { get; set; }

        [JsonProperty("attachments")]
        public Attachment[] Attachments { get; set; }
    }

    public partial class Attachment
    {
        [JsonProperty("url")]
        public Uri Url { get; set; }

        [JsonProperty("mime_type")]
        public MimeType MimeType { get; set; }

        [JsonProperty("size_in_bytes")]
        public long SizeInBytes { get; set; }

        [JsonProperty("duration_in_seconds")]
        public long DurationInSeconds { get; set; }
    }

    public enum MimeType { AudioMp3, AudioMpeg };

    public partial class DispatchFeed
    {
        public static DispatchFeed FromJson(string json) => JsonConvert.DeserializeObject<DispatchFeed>(json, Converter.Settings);
    }

    public static class Serialize
    {
        public static string ToJson(this DispatchFeed self) => JsonConvert.SerializeObject(self, Converter.Settings);
    }

    internal static class Converter
    {
        public static readonly JsonSerializerSettings Settings = new JsonSerializerSettings
        {
            MetadataPropertyHandling = MetadataPropertyHandling.Ignore,
            DateParseHandling = DateParseHandling.None,
            Converters =
            {
                MimeTypeConverter.Singleton,
                new IsoDateTimeConverter { DateTimeStyles = DateTimeStyles.AssumeUniversal }
            },
        };
    }

    internal class MimeTypeConverter : JsonConverter
    {
        public override bool CanConvert(Type t) => t == typeof(MimeType) || t == typeof(MimeType?);

        public override object ReadJson(JsonReader reader, Type t, object existingValue, JsonSerializer serializer)
        {
            if (reader.TokenType == JsonToken.Null) return null;
            var value = serializer.Deserialize<string>(reader);
            switch (value)
            {
                case "audio/mp3":
                    return MimeType.AudioMp3;
                case "audio/mpeg":
                    return MimeType.AudioMpeg;
            }
            throw new Exception("Cannot unmarshal type MimeType");
        }

        public override void WriteJson(JsonWriter writer, object untypedValue, JsonSerializer serializer)
        {
            if (untypedValue == null)
            {
                serializer.Serialize(writer, null);
                return;
            }
            var value = (MimeType)untypedValue;
            switch (value)
            {
                case MimeType.AudioMp3:
                    serializer.Serialize(writer, "audio/mp3");
                    return;
                case MimeType.AudioMpeg:
                    serializer.Serialize(writer, "audio/mpeg");
                    return;
            }
            throw new Exception("Cannot marshal type MimeType");
        }

        public static readonly MimeTypeConverter Singleton = new MimeTypeConverter();
    }
}
