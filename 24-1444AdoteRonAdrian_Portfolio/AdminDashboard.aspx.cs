using _24_1444AdoteRonAdrian_Portfolio.Security;
using System;
using System.Web;

namespace _24_1444AdoteRonAdrian_Portfolio
{
    // The admin dashboard's shell. It only checks who is asking and renders the components; every
    // figure and row is fetched from /AdminApi by the page's script.
    public partial class AdminDashboard : System.Web.UI.Page
    {
        public const string AdminConsoleName = Admin.AdminConsoleName;

        protected string CsrfToken
        {
            get { return AntiForgery.Token(Session); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // An ordinary user, or an admin who came in through LoginPage, gets the admin sign-in.
            if (!UserSession.IsAdmin(Session))
            {
                Response.Redirect("~/Admin.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // So Back after logging out shows the sign-in page rather than a cached dashboard.
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
        }
    }
}
