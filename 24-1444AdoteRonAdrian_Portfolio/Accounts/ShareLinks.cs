using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text.RegularExpressions;

namespace _24_1444AdoteRonAdrian_Portfolio.Accounts
{
    // The token behind an account's public link, SharePage.aspx?t=<token>, kept in users.share_token
    // (Database/Migrations/007_share_links.sql). The link is only as private as the token is hard to
    // guess, so it is 16 bytes from the crypto RNG rather than anything derived from the account.
    public static class ShareLinks
    {
        private static readonly string PortfolioConn =
            ConfigurationManager.ConnectionStrings["portfolio_conn"].ConnectionString;

        // The query-string key SharePage reads the token from.
        public const string TokenQuery = "t";

        // 16 bytes as lowercase hex; the column is char(32) to match.
        public const int TokenLength = 32;

        private static readonly Regex TokenShape = new Regex("^[0-9a-f]{" + TokenLength + "}$");

        // "" when the account has no link, or no longer exists.
        public static string Get(int userId)
        {
            using (var conn = new SqlConnection(PortfolioConn))
            using (var cmd = new SqlCommand("SELECT share_token FROM users WHERE id = @id", conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = userId;
                conn.Open();
                return cmd.ExecuteScalar() as string ?? "";
            }
        }

        // Replaces whatever link the account had, so an old one that was passed around too far stops
        // working the moment a new one is made. Null when the account is gone or deactivated.
        public static string Renew(int userId)
        {
            // A collision on 128 random bits won't happen in practice, but the unique index would
            // refuse it rather than hand two accounts the same page, so it is simply drawn again.
            for (int attempt = 0; attempt < 3; attempt++)
            {
                string token = NewToken();

                try
                {
                    return Write(userId, token) ? token : null;
                }
                catch (SqlException ex) when (AccountRules.IsDuplicateKey(ex))
                {
                }
            }

            throw new InvalidOperationException("Could not draw an unused share token.");
        }

        public static void Revoke(int userId)
        {
            Write(userId, null);
        }

        // The account a link belongs to, or null for a token that is malformed, withdrawn, or points
        // at an account an admin has deactivated -- the share page shows the same "not found" for all
        // of them, so a visitor can't tell a revoked link from one that never existed.
        public static int? Find(string token)
        {
            token = (token ?? "").Trim().ToLowerInvariant();

            // Checked before the query so arbitrary input never reaches the database.
            if (!TokenShape.IsMatch(token))
            {
                return null;
            }

            using (var conn = new SqlConnection(PortfolioConn))
            using (var cmd = new SqlCommand(
                "SELECT id FROM users WHERE share_token = @token AND status = @active", conn))
            {
                cmd.Parameters.Add("@token", SqlDbType.Char, TokenLength).Value = token;
                cmd.Parameters.Add("@active", SqlDbType.VarChar, 10).Value = AccountStatus.Active;
                conn.Open();
                return cmd.ExecuteScalar() as int?;
            }
        }

        // The full address, to be pasted anywhere, so it carries the scheme and host the request
        // came in on rather than a path relative to this site. Extensionless, because RouteConfig's
        // friendly URLs would only redirect a .aspx link there anyway.
        public static string Url(Uri request, string token)
        {
            return token.Length == 0
                ? ""
                : request.GetLeftPart(UriPartial.Authority) + "/SharePage?" + TokenQuery + "=" + token;
        }

        private static bool Write(int userId, string token)
        {
            using (var conn = new SqlConnection(PortfolioConn))
            using (var cmd = new SqlCommand(
                "UPDATE users SET share_token = @token WHERE id = @id AND status = @active", conn))
            {
                cmd.Parameters.Add("@token", SqlDbType.Char, TokenLength).Value = (object)token ?? DBNull.Value;
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@active", SqlDbType.VarChar, 10).Value = AccountStatus.Active;
                conn.Open();
                return cmd.ExecuteNonQuery() == 1;
            }
        }

        private static string NewToken()
        {
            var bytes = new byte[TokenLength / 2];

            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(bytes);
            }

            return BitConverter.ToString(bytes).Replace("-", "").ToLowerInvariant();
        }
    }
}
