using System;
using System.Collections.Generic;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminServices.Models
{
    // Everything the Analytics view draws, fetched in one request so the tiles and charts all
    // describe the same moment.
    public class AnalyticsSnapshot
    {
        public int TotalUsers { get; set; }
        public int ActiveUsers { get; set; }
        public int InactiveUsers { get; set; }
        public int NewLast30Days { get; set; }
        public int SignedInLast30Days { get; set; }

        public List<CountBucket> SignupsByMonth { get; set; }
        public List<CountBucket> LastSignIn { get; set; }
        public List<CountBucket> ProfileFields { get; set; }
        public List<UserSummary> RecentSignups { get; set; }

        public DateTime GeneratedAt { get; set; }
    }
}
