using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using _24_1444AdoteRonAdrian_Portfolio.Security;
using Microsoft.Ajax.Utilities;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

namespace _24_1444AdoteRonAdrian_Portfolio
{
    public partial class LoginPage : System.Web.UI.Page
    {
        public const string SiteBrandName = ContentPage.SiteBrandName;

        private static readonly string PortfolioConn =
            ConfigurationManager.ConnectionStrings["portfolio_conn"].ConnectionString;

        // One message for both an unknown username and a wrong password, so the form can't be used
        // to find out which usernames exist.
        private const string InvalidLoginMessage = "invalid username or password.";
        private const string ForAdminMessage = "hey, you the admin? no not here, somewhere...";

        protected void loginSubmit_Click(object sender, EventArgs e)
        {
            try
            {
                string username = loginUser.Text.Trim();
                int userId = 0;
                string storedHash = null;
                string fullName = null;
                string status = null;
                string role = null;

                using (var conn = new SqlConnection(PortfolioConn))
                using (var cmd = new SqlCommand(
                    "SELECT id, password_hash, username, first_name, middle_name, last_name, suffix, status, role " +
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
                            // The match ignores case, so keep the username as it was registered, not as typed.
                            username = reader.GetString(2);
                            fullName = UserSession.FullName(
                                TextOrNull(reader, 3), TextOrNull(reader, 4), TextOrNull(reader, 5), TextOrNull(reader, 6));
                            status = reader.GetString(7);
                            role = TextOrNull(reader, 8);
                        }
                    }
                }

                // Admins sign in through Admin.aspx. They're turned away here with the same message as a
                // bad password, and only after the hash check, so neither the text nor the response time
                // gives away which usernames are admins.
                bool passwordOk = storedHash != null && PasswordHasher.Verify(loginPassword.Text, storedHash);
                bool isAdmin = string.Equals(role, UserSession.AdminRole, StringComparison.OrdinalIgnoreCase);

                if (!passwordOk)
                {
                    loginStatus.Text = InvalidLoginMessage;
                    loginStatus.CssClass = "login-status is-error";
                    return;
                }

                if (isAdmin)
                {
                    loginStatus.Text = ForAdminMessage;
                    loginStatus.CssClass = "login-status is-error";
                    return;
                }

                // Only said after the password checks out, so it doesn't reveal which usernames exist.
                if (status != AccountStatus.Active)
                {
                    loginStatus.Text = AccountStatus.DeactivatedMessage;
                    loginStatus.CssClass = "login-status is-error";
                    return;
                }

                AccountActivity.RecordSignIn(userId);
                UserSession.SignIn(Session, userId, username, fullName);
                Response.Redirect("ContentPage.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            // The raw exception text can name the server or the schema, so it goes to the trace log
            // and the visitor gets a generic line instead.
            catch (SqlException ex)
            {
                Trace.Warn("LoginPage", "Sign-in query failed", ex);
                loginStatus.Text = "can't reach the server right now. try again in a moment.";
                loginStatus.CssClass = "login-status is-error";
            }
            catch (Exception ex)
            {
                // e.g. a malformed stored hash making PasswordHasher.Verify throw.
                Trace.Warn("LoginPage", "Sign-in failed", ex);
                loginStatus.Text = "something went wrong. please try again.";
                loginStatus.CssClass = "login-status is-error";
            }
        }

        private static string TextOrNull(SqlDataReader reader, int column)
        {
            return reader.IsDBNull(column) ? null : reader.GetString(column);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // ProfilePage's log-out lands here with a flag, so the screen can confirm it.
            if (!IsPostBack && Request.QueryString[ProfilePage.SignedOutQuery] == "1")
            {
                loginStatus.Text = "signed out. see you next time.";
            }
            
        }
    }
}
