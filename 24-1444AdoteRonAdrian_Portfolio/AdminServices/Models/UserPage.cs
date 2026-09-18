using System.Collections.Generic;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminServices.Models
{
    // One page of search results. Page is the page actually returned, which is clamped to the last
    // one when a deletion leaves the requested page empty.
    public class UserPage
    {
        public List<UserSummary> Items { get; set; }
        public int Total { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
    }
}
