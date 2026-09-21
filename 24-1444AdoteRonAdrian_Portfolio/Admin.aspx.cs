using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using _24_1444AdoteRonAdrian_Portfolio.Security;
using System;
using System.Configuration;
using System.Data.SqlClient;

namespace _24_1444AdoteRonAdrian_Portfolio
{
    public partial class Admin : System.Web.UI.Page
    {
        public const string SiteBrandName = ContentPage.SiteBrandName;
        public const string AdminConsoleName = "Portfolio Admin";
        public const string BrandInitials = "IA";

        // Where a signed-in admin lands, and where the dashboard's log-out sends them back from.
        public const string AdminHomeUrl = "AdminDashboard.aspx";
        public const string SignedOutQuery = "signedout";

        private static readonly string PortfolioConn =
            ConfigurationManager.ConnectionStrings["portfolio_conn"].ConnectionString;

        // Unknown username, wrong password, "right password but not an admin" and a deactivated admin
        // all get the same message, so the form reveals neither which usernames exist nor which
        // accounts are admins. Kept to one line in the alert: the page is sized to fit the viewport
        // without scrolling.
        private const string InvalidLoginMessage = "Invalid credentials or access denied.";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            if (UserSession.IsAdmin(Session))
            {
                Response.Redirect(AdminHomeUrl, false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (Request.QueryString[SignedOutQuery] == "1")
            {
                adminStatus.Text = "You have been signed out.";
                adminStatus.CssClass = "adm-alert adm-alert--info is-visible";
            }
        }

        protected void adminSubmit_Click(object sender, EventArgs e)
        {
            string username = adminUser.Text.Trim();
            int userId = 0;
            string storedHash = null;
            string role = null;
            string fullName = null;
            string status = null;

            try
            {
                using (var conn = new SqlConnection(PortfolioConn))
                using (var cmd = new SqlCommand(
                    "SELECT id, password_hash, username, role, first_name, middle_name, last_name, suffix, status " +
                    "FROM users WHERE username = @username", conn))
                {
                    cmd.Parameters.AddWithValue("@username", username);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            userId = reader.GetInt32(0);
                            storedHash = TextOrNull(reader, 1);
                            username = reader.GetString(2);
                            role = TextOrNull(reader, 3);
                            fullName = UserSession.FullName(
                                TextOrNull(reader, 4), TextOrNull(reader, 5), TextOrNull(reader, 6), TextOrNull(reader, 7));
                            status = reader.GetString(8);
                        }
                    }
                }

                // The hash is checked before the role, so a non-admin costs the same PBKDF2 work as an
                // admin and the response time doesn't give the role away.
                bool passwordOk = storedHash != null && PasswordHasher.Verify(adminPassword.Text, storedHash);
                bool isAdmin = string.Equals(role, UserSession.AdminRole, StringComparison.OrdinalIgnoreCase);

                if (!passwordOk || !isAdmin || status != AccountStatus.Active)
                {
                    adminStatus.Text = InvalidLoginMessage;
                    adminStatus.CssClass = "adm-alert is-visible";
                    return;
                }

                AccountActivity.RecordSignIn(userId);
            }
            // The raw exception can name the server or the schema, so it goes to the trace log.
            catch (SqlException ex)
            {
                Trace.Warn("Admin", "Admin sign-in query failed", ex);
                // Short enough for the alert's single line, like InvalidLoginMessage.
                adminStatus.Text = "Server unavailable. Try again shortly.";
                adminStatus.CssClass = "adm-alert is-visible";
                return;
            }

            UserSession.SignIn(Session, userId, username, fullName, UserSession.AdminRole);
            Response.Redirect(AdminHomeUrl, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private static string TextOrNull(SqlDataReader reader, int column)
        {
            return reader.IsDBNull(column) ? null : reader.GetString(column);
        }
    }
}
