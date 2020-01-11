using System;
using System.Linq;
using Microsoft.WindowsAzure.Storage.Table;

namespace NintendoDispatch.Models
{
    public class Episode : TableEntity
    {
        public Episode()
        {
        }

        public Episode(EpisodeItem item)
        {
            PartitionKey = "Default";
            RowKey = item.Id.ToString();
            Id = item.Id;
            PublishedDate = item.DatePublished;
            Title = item.Title;
            Url = item.Url.AbsoluteUri;
            Summary = item.Summary;

            if (item.Attachments?.Any() == true)
            {
                var attachment = item.Attachments[0];

                AttachmentUrl = attachment.Url.AbsoluteUri;
                SizeInBytes = attachment.SizeInBytes;
                DurationInSeconds = attachment.DurationInSeconds;
            }
        }

        public System.Guid Id { get; set; }
        public DateTime PublishedDate { get; set; }
        public string Title { get; set; }
        public string Url { get; set; }
        public string Content { get; set; }
        public string Summary { get; set; }
        public string AttachmentUrl { get; set; }
        public long SizeInBytes { get; set; }
        public long DurationInSeconds { get; set; }
    }   
}
