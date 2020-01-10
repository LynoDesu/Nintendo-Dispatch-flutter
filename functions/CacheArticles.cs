using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Xml.Serialization;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using Microsoft.WindowsAzure.Storage.Table;
using NintendoDispatch.Functions;
using NintendoDispatch.Models;

namespace NintendoDispatch.Functions
{
    public static class CacheArticles
    {
        [FunctionName("CacheArticles")]
        public static async Task Run(
            [TimerTrigger("0 */1 * * * *")]TimerInfo myTimer,
            ILogger log,
            [Table("articles", Connection = "MY_STORAGE_ACCT_APP_SETTING")]IAsyncCollector<Article> articleTable,
            [Table("articles", "Default", Connection = "MY_STORAGE_ACCT_APP_SETTING")]CloudTable tableQuery)
        {
            log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");

            string xml = string.Empty;
            int attempts = 0;

            while (string.IsNullOrEmpty(xml) && attempts < 10)
            {
                if (attempts > 0)
                {
                    await Task.Delay(1000);
                }

                log.LogInformation($"Trying to get xml....attempt {attempts}");

                xml = await Connections.Client.GetStringAsync("https://www.nintendodispatch.com/articles/rss");

                attempts++;
            }

            if (!string.IsNullOrEmpty(xml))
            {
                RssFeed result = null;
                XmlSerializer serializer = new XmlSerializer(typeof(RssFeed));
                using (TextReader reader = new StringReader(xml))
                {
                    result = (RssFeed)serializer.Deserialize(reader);
                }

                if (result != null)
                {
                    var latestDate = await GetLatestArticleDate(tableQuery);

                    var newArticles = result.Channel.Articles.Where(x => DateTime.Parse(x.PubDate) > latestDate);

                    if (newArticles?.Count() > 0)
                    {
                        var newestArticle = newArticles.OrderByDescending(x => DateTime.Parse(x.PubDate)).First();

                        foreach (var article in newArticles)
                        {
                            await articleTable.AddAsync(new Article(article));
                        }

                        log.LogInformation($"Added {newArticles.Count()} new articles ^_^");

                        var replaceOperation = TableOperation.InsertOrReplace(new Article
                        {
                            PartitionKey = "CurrentLatest",
                            RowKey = "1",
                            PubDate = DateTime.Parse(newestArticle.PubDate)
                        });

                        var replaceResult = await tableQuery.ExecuteAsync(replaceOperation);

                        log.LogInformation($"Replace CurrentLatest row result status code: {replaceResult.HttpStatusCode}");
                    }
                }
            }
        }

        private static async Task<DateTime> GetLatestArticleDate(CloudTable cloudTable)
        {
            var latestDate = DateTime.MinValue;

            var selectOperation = TableOperation.Retrieve<Article>("CurrentLatest", "1");

            var result = await cloudTable.ExecuteAsync(selectOperation);

            if (result?.Result is Article article)
            {
                latestDate = article.PubDate;
            }

            return latestDate;
        }
    }
}
