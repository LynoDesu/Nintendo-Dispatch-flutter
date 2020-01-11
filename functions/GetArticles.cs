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
    public static class GetArticles
    {
        [FunctionName("GetArticles")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = "Articles/List")] HttpRequest req,
            ILogger log,
            [Table("articles", "Default", Connection = "MY_STORAGE_ACCT_APP_SETTING")]CloudTable tableQuery)
        {
            log.LogInformation("Starting GetArticles function");

            string dateFrom = req.Query["dateFrom"];

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            dateFrom = dateFrom ?? data?.dateFrom;

            log.LogInformation($"dateFrom: {dateFrom}");

            var partitionFilter = TableQuery.GenerateFilterCondition(nameof(Article.PartitionKey), QueryComparisons.Equal, "Default");
            var query = new TableQuery<Article>().Where(partitionFilter);
            TableContinuationToken token = null;
            var ArticleList = new List<Article>();

            if (DateTime.TryParse(dateFrom, out DateTime parsedDate))
            {
                var dateFilter = TableQuery.GenerateFilterConditionForDate(nameof(Article.PubDate), QueryComparisons.GreaterThan, parsedDate);
                log.LogInformation($"dateQuery: {dateFilter}");

                query = query.Where(TableQuery.CombineFilters(partitionFilter, TableOperators.And, dateFilter));
            }

            do
            {
                TableQuerySegment<Article> segment = await tableQuery.ExecuteQuerySegmentedAsync<Article>(query, token);

                ArticleList.AddRange(segment.Results);

            } while (token != null);

            return new OkObjectResult(ArticleList.OrderByDescending(x => x.PubDate));
        }
    }
}
