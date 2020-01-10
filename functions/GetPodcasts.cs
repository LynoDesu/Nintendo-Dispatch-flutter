using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.WindowsAzure.Storage.Table;
using NintendoDispatch.Models;
using System.Collections.Generic;
using System.Linq;

namespace NintendoDispatch.Functions
{
    public static class GetPodcasts
    {
        [FunctionName("GetPodcasts")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = "Podcasts/List")] HttpRequest req,
            ILogger log,
            [Table("episodes", "Default", Connection = "MY_STORAGE_ACCT_APP_SETTING")]CloudTable tableQuery)
        {
            log.LogInformation("Starting GetPodcasts function");

            string dateFrom = req.Query["dateFrom"];

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            dateFrom = dateFrom ?? data?.dateFrom;

            log.LogInformation($"dateFrom: {dateFrom}");

            var partitionFilter = TableQuery.GenerateFilterCondition(nameof(Episode.PartitionKey), QueryComparisons.Equal, "Default");
            var query = new TableQuery<Episode>().Where(partitionFilter);
            TableContinuationToken token = null;
            var episodeList = new List<Episode>();

            if (DateTime.TryParse(dateFrom, out DateTime parsedDate))
            {
                var dateFilter = TableQuery.GenerateFilterConditionForDate(nameof(Episode.PublishedDate), QueryComparisons.GreaterThan, parsedDate);
                log.LogInformation($"dateQuery: {dateFilter}");

                query = query.Where(TableQuery.CombineFilters(partitionFilter, TableOperators.And, dateFilter));
            }

            do
            {
                TableQuerySegment<Episode> segment = await tableQuery.ExecuteQuerySegmentedAsync<Episode>(query, token);

                episodeList.AddRange(segment.Results);

            } while (token != null);

            return new OkObjectResult(episodeList.OrderByDescending(x => x.PublishedDate));
        }
    }
}
