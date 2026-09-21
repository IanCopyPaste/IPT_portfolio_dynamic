using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace _24_1444AdoteRonAdrian_Portfolio.Accounts
{
    // The values of users.status. The column's check constraint allows exactly these two, so anything
    // else coming in from a request is refused here before it reaches the database.
    public static class AccountStatus
    {
        public const string Active = "active";
        public const string Inactive = "inactive";

        public const string DeactivatedMessage = "this account has been deactivated.";

        private static readonly string PortfolioConn =
            ConfigurationManager.ConnectionStrings["portfolio_conn"].ConnectionString;

        public static bool IsValid(string value)
        {
            return value == Active || value == Inactive;
        }

        // False for an account that is gone or was deactivated. The sign-in pages only check status
        // once, at sign-in, so a page that shows a signed-in user's own data asks again: an admin
        // who deactivates someone expects them to be locked out now, not when their session expires.
        public static bool IsActive(int userId)
        {
            using (var conn = new SqlConnection(PortfolioConn))
            using (var cmd = new SqlCommand("SELECT 1 FROM users WHERE id = @id AND status = @active", conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@active", SqlDbType.VarChar, 10).Value = Active;
                conn.Open();
                return cmd.ExecuteScalar() != null;
            }
        }
    }
}
