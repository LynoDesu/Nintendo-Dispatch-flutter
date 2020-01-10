using System;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using Microsoft.WindowsAzure.Storage.Table;
using NintendoDispatch.Models;

namespace NintendoDispatch.Functions
{
    public static class CachePodcasts
    {
        [FunctionName("CachePodcasts")]
        public static async Task Run(
            [TimerTrigger("0 0 */1 * * *")]TimerInfo myTimer,
            ILogger log,
            [Table("episodes", Connection = "MY_STORAGE_ACCT_APP_SETTING")]IAsyncCollector<Episode> episodeTable,
            [Table("episodes", "Default", Connection = "MY_STORAGE_ACCT_APP_SETTING")]CloudTable tableQuery)
        {
            string json = string.Empty;
            int attempts = 0;

            while (string.IsNullOrEmpty(json) && attempts < 10)
            {
                if (attempts > 0)
                {
                    await Task.Delay(1000);
                }

                log.LogInformation($"Trying to get json....attempt {attempts}");

                json = await Connections.Client.GetStringAsync("https://www.nintendodispatch.com/json");

                attempts++;
            }

            if (!string.IsNullOrEmpty(json))
            {
                var latestDate = await GetLatestEpisodeDate(tableQuery);

                var feed = DispatchFeed.FromJson(json);

                var newestEpisode = feed.Items.OrderByDescending(x => x.DatePublished).FirstOrDefault();

                var newEpisodes = feed.Items.Where(x => x.DatePublished > latestDate);

                if (newEpisodes?.Count() > 0)
                {
                    foreach (var episode in newEpisodes)
                    {
                        await episodeTable.AddAsync(new Episode(episode));
                    }

                    log.LogInformation($"Added {newEpisodes.Count()} new episodes ^_^");

                    var replaceOperation = TableOperation.InsertOrReplace(new Episode
                    {
                        PartitionKey = "CurrentLatest",
                        RowKey = "1",
                        PublishedDate = newestEpisode.DatePublished
                    });

                    var result = await tableQuery.ExecuteAsync(replaceOperation);

                    log.LogInformation($"Replace CurrentLatest row result status code: {result.HttpStatusCode}");
                }
                else
                {
                    log.LogInformation($"No new episodes were found");
                }
            }
            else
            {
                log.LogInformation("Json result was empty");
            }
        }

        private static async Task<DateTime> GetLatestEpisodeDate(CloudTable cloudTable)
        {
            var latestDate = DateTime.MinValue;

            var selectOperation = TableOperation.Retrieve<Episode>("CurrentLatest", "1");

            var result = await cloudTable.ExecuteAsync(selectOperation);

            if (result?.Result is Episode episode)
            {
                latestDate = episode.PublishedDate;
            }

            return latestDate;
        }
    }
}
