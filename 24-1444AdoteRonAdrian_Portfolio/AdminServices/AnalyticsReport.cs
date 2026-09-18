using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using _24_1444AdoteRonAdrian_Portfolio.AdminServices.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminServices
{
    // The figures behind the Analytics view. Administrator accounts are left out of every figure: the
    // view is about the people who signed up to the portfolio, not the people running it.
    public static class AnalyticsReport
    {
        public const int MonthsShown = 12;
        public const int RecentShown = 5;

        // COUNT(CASE ...) rather than SUM, because SUM over an empty table is NULL and COUNT is 0.
        private const string CountsSql =
            "SELECT COUNT(*), " +
            "COUNT(CASE WHEN status = '" + AccountStatus.Active + "' THEN 1 END), " +
            "COUNT(CASE WHEN status = '" + AccountStatus.Inactive + "' THEN 1 END), " +
            "COUNT(CASE WHEN created_at >= DATEADD(day, -30, @now) THEN 1 END), " +
            "COUNT(CASE WHEN last_login_at >= DATEADD(day, -7, @now) THEN 1 END), " +
            "COUNT(CASE WHEN last_login_at < DATEADD(day, -7, @now) AND last_login_at >= DATEADD(day, -30, @now) THEN 1 END), " +
            "COUNT(CASE WHEN last_login_at < DATEADD(day, -30, @now) AND last_login_at >= DATEADD(day, -90, @now) THEN 1 END), " +
            "COUNT(CASE WHEN last_login_at < DATEADD(day, -90, @now) THEN 1 END), " +
            "COUNT(CASE WHEN last_login_at IS NULL THEN 1 END), " +
            "COUNT(NULLIF(email, '')), COUNT(NULLIF(sms, '')), COUNT(NULLIF(middle_name, '')), COUNT(NULLIF(suffix, '')) " +
            "FROM users WHERE role <> @admin";

        private const string MonthsSql =
            "SELECT YEAR(created_at), MONTH(created_at), COUNT(*) FROM users " +
            "WHERE role <> @admin AND created_at >= @from " +
            "GROUP BY YEAR(created_at), MONTH(created_at)";

        public static AnalyticsSnapshot Build()
        {
            // One clock for every window, so a boundary can't fall between two of the queries.
            DateTime now = DateTime.UtcNow;
            var snapshot = new AnalyticsSnapshot { GeneratedAt = now };

            using (SqlConnection conn = Db.Open())
            {
                ReadCounts(conn, now, snapshot);
                snapshot.SignupsByMonth = ReadMonths(conn, now);
                snapshot.RecentSignups = ReadRecent(conn);
            }

            return snapshot;
        }

        private static void ReadCounts(SqlConnection conn, DateTime now, AnalyticsSnapshot snapshot)
        {
            using (var cmd = new SqlCommand(CountsSql, conn))
            {
                cmd.Parameters.Add("@now", SqlDbType.DateTime2).Value = now;
                Db.AddAdminRole(cmd);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    reader.Read();
                    snapshot.TotalUsers = reader.GetInt32(0);
                    snapshot.ActiveUsers = reader.GetInt32(1);
                    snapshot.InactiveUsers = reader.GetInt32(2);
                    snapshot.NewLast30Days = reader.GetInt32(3);
                    snapshot.SignedInLast30Days = reader.GetInt32(4) + reader.GetInt32(5);

                    snapshot.LastSignIn = new List<CountBucket>
                    {
                        new CountBucket("7d", "Last 7 days", reader.GetInt32(4)),
                        new CountBucket("30d", "8 to 30 days ago", reader.GetInt32(5)),
                        new CountBucket("90d", "31 to 90 days ago", reader.GetInt32(6)),
                        new CountBucket("older", "Over 90 days ago", reader.GetInt32(7)),
                        new CountBucket("never", "Never signed in", reader.GetInt32(8))
                    };

                    snapshot.ProfileFields = new List<CountBucket>
                    {
                        new CountBucket("email", "Email address", reader.GetInt32(9)),
                        new CountBucket("sms", "Mobile number", reader.GetInt32(10)),
                        new CountBucket("middle", "Middle name", reader.GetInt32(11)),
                        new CountBucket("suffix", "Name suffix", reader.GetInt32(12))
                    };
                }
            }
        }

        // The last twelve calendar months (UTC), oldest first, with empty months filled in as zero so
        // the chart's x-axis is continuous.
        private static List<CountBucket> ReadMonths(SqlConnection conn, DateTime now)
        {
            var firstMonth = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc).AddMonths(1 - MonthsShown);
            var counts = new Dictionary<string, int>();

            using (var cmd = new SqlCommand(MonthsSql, conn))
            {
                cmd.Parameters.Add("@from", SqlDbType.DateTime2).Value = firstMonth;
                Db.AddAdminRole(cmd);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        counts[MonthKey(reader.GetInt32(0), reader.GetInt32(1))] = reader.GetInt32(2);
                    }
                }
            }

            var months = new List<CountBucket>();

            for (int i = 0; i < MonthsShown; i++)
            {
                DateTime month = firstMonth.AddMonths(i);
                string key = MonthKey(month.Year, month.Month);
                int count;
                counts.TryGetValue(key, out count);
                months.Add(new CountBucket(key, month.ToString("MMM yyyy", CultureInfo.InvariantCulture), count));
            }

            return months;
        }

        private static List<UserSummary> ReadRecent(SqlConnection conn)
        {
            var recent = new List<UserSummary>();

            using (var cmd = new SqlCommand(
                "SELECT TOP (@take) " + Db.SummaryColumns + " FROM users WHERE role <> @admin " +
                "ORDER BY created_at DESC, id DESC", conn))
            {
                cmd.Parameters.Add("@take", SqlDbType.Int).Value = RecentShown;
                Db.AddAdminRole(cmd);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        recent.Add(Db.ReadSummary(reader, new UserSummary()));
                    }
                }
            }

            return recent;
        }

        private static string MonthKey(int year, int month)
        {
            return year.ToString("0000", CultureInfo.InvariantCulture) + "-" + month.ToString("00", CultureInfo.InvariantCulture);
        }
    }
}
