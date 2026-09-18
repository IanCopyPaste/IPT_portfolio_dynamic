using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace _24_1444AdoteRonAdrian_Portfolio.Accounts
{
    // Writes users.last_login_at, which the admin analytics read. Every page that signs someone in
    // calls this, so the "last sign-in" figures can't miss one of the ways in.
    public static class AccountActivity
    {
        private static readonly string PortfolioConn =
            ConfigurationManager.ConnectionStrings["portfolio_conn"].ConnectionString;

        public static void RecordSignIn(int userId)
        {
            using (var conn = new SqlConnection(PortfolioConn))
            using (var cmd = new SqlCommand("UPDATE users SET last_login_at = SYSUTCDATETIME() WHERE id = @id", conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = userId;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }
}
