using System;
using System.Web.UI;

namespace _24_1444AdoteRonAdrian_Portfolio
{
    public partial class ForbiddenPage : System.Web.UI.Page
    {
        public const string SiteBrandName = ContentPage.SiteBrandName;

        // Request.RawUrl still names the page that was refused when another page hands over with
        // Server.Transfer, so the terminal can say what was blocked. It comes from the URL, so the
        // markup emits it with <%: %> to encode it.
        protected string RequestedPath
        {
            get { return Request.RawUrl; }
        }

        // Opened directly, "try again" would only reload this page, so it points at the portfolio instead.
        protected string RetryPath
        {
            get
            {
                bool openedDirectly = string.Equals(Request.Path, Request.CurrentExecutionFilePath,
                    StringComparison.OrdinalIgnoreCase);
                return openedDirectly ? "ContentPage.aspx" : Request.RawUrl;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.StatusCode = 403;
            // Without this, IIS can swap the page for its own generic 403 screen.
            Response.TrySkipIisCustomErrors = true;
        }
    }
}
