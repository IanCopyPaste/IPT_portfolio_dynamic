using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using _24_1444AdoteRonAdrian_Portfolio.AdminServices.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminServices
{
    // The users table as the dashboard sees it: searched and paged, one account in detail, and the two
    // changes an admin may make. Both changes skip admin rows in the WHERE clause itself, so a forged
    // request can't get round the rule the client greys out.
    public static class UserDirectory
    {
        public static readonly int[] PageSizes = { 10, 25, 50 };
        public const int DefaultPageSize = 10;
        public const int MaxQueryLength = 100;

        private const string Filter =
            "WHERE (@pattern IS NULL OR first_name LIKE @pattern ESCAPE '\\' OR middle_name LIKE @pattern ESCAPE '\\' " +
            "OR last_name LIKE @pattern ESCAPE '\\' OR username LIKE @pattern ESCAPE '\\' " +
            "OR (first_name + ' ' + last_name) LIKE @pattern ESCAPE '\\') " +
            "AND (@status IS NULL OR status = @status)";

        public static UserPage Search(string query, string status, int page, int pageSize)
        {
            string pattern = LikePattern(query);
            string statusFilter = AccountStatus.IsValid(status) ? status : null;
            var result = new UserPage { Items = new List<UserSummary>(), PageSize = pageSize };

            using (SqlConnection conn = Db.Open())
            {
                using (var count = new SqlCommand("SELECT COUNT(*) FROM users " + Filter, conn))
                {
                    AddFilter(count, pattern, statusFilter);
                    result.Total = (int)count.ExecuteScalar();
                }

                int lastPage = Math.Max(1, (result.Total + pageSize - 1) / pageSize);
                result.Page = Math.Min(Math.Max(1, page), lastPage);

                using (var list = new SqlCommand(
                    "SELECT " + Db.SummaryColumns + " FROM users " + Filter +
                    " ORDER BY created_at DESC, id DESC OFFSET @offset ROWS FETCH NEXT @size ROWS ONLY", conn))
                {
                    AddFilter(list, pattern, statusFilter);
                    list.Parameters.Add("@offset", SqlDbType.Int).Value = (result.Page - 1) * pageSize;
                    list.Parameters.Add("@size", SqlDbType.Int).Value = pageSize;

                    using (SqlDataReader reader = list.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            result.Items.Add(Db.ReadSummary(reader, new UserSummary()));
                        }
                    }
                }
            }

            return result;
        }

        // Null when there's no such account.
        public static UserDetail Find(int id)
        {
            using (SqlConnection conn = Db.Open())
            using (var cmd = new SqlCommand(
                "SELECT " + Db.SummaryColumns + ", address, sms FROM users WHERE id = @id", conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = id;

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        return null;
                    }

                    UserDetail detail = Db.ReadSummary(reader, new UserDetail());
                    detail.FirstName = Db.Text(reader, 1);
                    detail.MiddleName = Db.Text(reader, 2);
                    detail.LastName = Db.Text(reader, 3);
                    detail.Suffix = Db.Text(reader, 4);
                    detail.Address = Db.Text(reader, 11);
                    detail.Sms = Db.Text(reader, 12);
                    return detail;
                }
            }
        }

        // False when the account is gone or belongs to an admin.
        public static bool SetStatus(int id, string status)
        {
            return Execute("UPDATE users SET status = @status WHERE id = @id AND role <> @admin", id,
                cmd => cmd.Parameters.Add("@status", SqlDbType.VarChar, 10).Value = status);
        }

        public static bool Delete(int id)
        {
            return Execute("DELETE FROM users WHERE id = @id AND role <> @admin", id, null);
        }

        private static bool Execute(string sql, int id, Action<SqlCommand> addParameters)
        {
            using (SqlConnection conn = Db.Open())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = id;
                Db.AddAdminRole(cmd);
                addParameters?.Invoke(cmd);
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        private static void AddFilter(SqlCommand cmd, string pattern, string status)
        {
            // Room for every character escaped plus the two wildcards.
            cmd.Parameters.Add("@pattern", SqlDbType.VarChar, MaxQueryLength * 2 + 2).Value = (object)pattern ?? DBNull.Value;
            cmd.Parameters.Add("@status", SqlDbType.VarChar, 10).Value = (object)status ?? DBNull.Value;
        }

        // "%text%" for a contains-match. %, _ and [ are LIKE wildcards, and usernames often contain an
        // underscore, so each is escaped to match only itself.
        private static string LikePattern(string query)
        {
            string trimmed = (query ?? "").Trim();

            if (trimmed.Length == 0)
            {
                return null;
            }

            if (trimmed.Length > MaxQueryLength)
            {
                trimmed = trimmed.Substring(0, MaxQueryLength);
            }

            return "%" + trimmed.Replace("\\", "\\\\").Replace("%", "\\%").Replace("_", "\\_").Replace("[", "\\[") + "%";
        }
    }
}
