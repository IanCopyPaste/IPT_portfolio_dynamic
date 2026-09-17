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

        protected void loginSubmit_Click(object sender, EventArgs e)
        {
            string username = loginUser.Text.Trim();
            int userId = 0;
            string storedHash = null;

            using (var conn = new SqlConnection(PortfolioConn))
            using (var cmd = new SqlCommand(
                "SELECT id, password_hash FROM users WHERE username = @username", conn))
            {
                cmd.Parameters.AddWithValue("@username", username);
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        userId = reader.GetInt32(0);
                        storedHash = reader.IsDBNull(1) ? null : reader.GetString(1);
                    }
                }
            }

            if (storedHash == null || !PasswordHasher.Verify(loginPassword.Text, storedHash))
            {
                loginStatus.Text = InvalidLoginMessage;
                loginStatus.CssClass = "login-status is-error";
                return;
            }

            // ContentPage checks these two keys.
            Session["user_id"] = userId;
            Session["username"] = username;
            Response.Redirect("ContentPage.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            
        }
    }
}
