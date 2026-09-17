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

        protected void loginSubmit_Click(object sender, EventArgs e)
        {
            using (var conn = new SqlConnection(PortfolioConn))
            using (var cmd = new SqlCommand("SELECT * FROM users WHERE username=@username", conn))
            {
                cmd.Parameters.AddWithValue("@username", loginUser.Text.Trim());
                conn.Open();
                cmd.ExecuteReader();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        //pretend to be success
                    }
                    else
                    {
                        //directly return a response in html by accessing a null label and turning it maybe visible
                        //you can say "Invalid username or password" in the label
                    }
                }
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            
        }
    }
}
