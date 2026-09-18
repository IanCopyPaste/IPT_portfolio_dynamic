using _24_1444AdoteRonAdrian_Portfolio.AdminServices.Models;
using _24_1444AdoteRonAdrian_Portfolio.Security;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminServices
{
    // Connection and row-reading helpers shared by the dashboard's services.
    internal static class Db
    {
        private static readonly string PortfolioConn =
            ConfigurationManager.ConnectionStrings["portfolio_conn"].ConnectionString;

        // The columns ReadSummary expects, in its order. A query that needs more appends them after.
        public const string SummaryColumns =
            "id, first_name, middle_name, last_name, suffix, username, email, role, status, created_at, last_login_at";

        public static SqlConnection Open()
        {
            var conn = new SqlConnection(PortfolioConn);
            conn.Open();
            return conn;
        }

        public static void AddAdminRole(SqlCommand cmd)
        {
            cmd.Parameters.Add("@admin", SqlDbType.VarChar, 10).Value = UserSession.AdminRole;
        }

        public static T ReadSummary<T>(SqlDataReader reader, T into) where T : UserSummary
        {
            into.Id = reader.GetInt32(0);
            into.FullName = UserSession.FullName(Text(reader, 1), Text(reader, 2), Text(reader, 3), Text(reader, 4));
            into.Username = Text(reader, 5);
            into.Email = Text(reader, 6);
            into.Role = Text(reader, 7);
            into.Status = Text(reader, 8);
            into.CreatedAt = Utc(reader.GetDateTime(9));
            into.LastLoginAt = reader.IsDBNull(10) ? (DateTime?)null : Utc(reader.GetDateTime(10));
            into.IsProtected = string.Equals(into.Role, UserSession.AdminRole, StringComparison.OrdinalIgnoreCase);
            return into;
        }

        public static string Text(SqlDataReader reader, int column)
        {
            return reader.IsDBNull(column) ? null : reader.GetString(column);
        }

        // The columns hold UTC (SYSUTCDATETIME) but come back unlabelled; marked here so the JSON
        // carries a "Z" and the browser converts them to the viewer's local time.
        public static DateTime Utc(DateTime value)
        {
            return DateTime.SpecifyKind(value, DateTimeKind.Utc);
        }
    }
}
