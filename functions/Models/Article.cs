using System;
using System.Collections.Generic;
using Microsoft.WindowsAzure.Storage.Table;
using NintendoDispatch.Models;

namespace NintendoDispatch.Models
{
    public class Article : TableEntity
    {
        public Article()
        {
        }

        public Article(RssArticle rssArticle)
        {
            PartitionKey = "Default";
            RowKey = rssArticle.Guid.Text;
            Title = rssArticle.Title;
            Link = rssArticle.Link2;
            Id = System.Guid.Parse(rssArticle.Guid.Text);
            PubDate = DateTime.Parse(rssArticle.PubDate);
            Authors = string.Join(",", rssArticle.Author);
            Description = rssArticle.Description;
            Content = rssArticle.Encoded;
        }

        public string Title { get; set; }
        public string Link { get; set; }
        public System.Guid Id { get; set; }
        public DateTime PubDate { get; set; }
        public string Authors { get; set; }
        public string Description { get; set; }
        public string Content { get; set; }
    }
}
