using System;
using System.Web;

namespace _24_1444AdoteRonAdrian_Portfolio
{
    // Where Web.config's customErrors sends anything a page didn't catch, and any .aspx address that
    // doesn't exist. It touches neither the session nor the database, so it still renders when one
    // of those is what failed. What went wrong is logged by Global.Application_Error, never shown.
    public partial class ErrorPage : System.Web.UI.Page
    {
        public const string SiteBrandName = ContentPage.SiteBrandName;

        protected int Code { get; private set; }

        protected string Kicker { get; private set; }
        protected string Heading { get; private set; }
        protected string Copy { get; private set; }
        protected string LogResult { get; private set; }
        protected string StatusName { get; private set; }

        // customErrors hands the error over by rewriting to this page, so RawUrl still names the
        // address the visitor asked for. It comes from the URL, so the markup encodes it.
        protected string RequestedPath
        {
            get { return Request.RawUrl; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Exception error = Server.GetLastError();

            if (Request.QueryString["code"] == "404")
            {
                Show(404, "not found", "Page not found", "Not Found", "[ missing ]",
                    "There's nothing at this address. Check the link, or head back to the start.");
            }
            // Thrown before the page runs when a field holds something that looks like HTML. The
            // forms check for it first, so this is a browser without script or a hand-made post.
            else if (error != null && error.GetBaseException() is HttpRequestValidationException)
            {
                Show(400, "bad request", "Couldn't accept that", "Bad Request", "[ refused ]",
                    "Something you typed contains a \"<\" right before a letter or symbol, or \"&#\", " +
                    "which this site can't accept. Go back, take it out, and try again.");
            }
            else
            {
                Show(500, "server error", "Something broke", "Internal Server Error", "[ failed ]",
                    "That didn't work on our end. Nothing you did caused it. Try again in a moment.");
            }

            Response.StatusCode = Code;
            // Without this, IIS can swap the page for its own generic error screen.
            Response.TrySkipIisCustomErrors = true;
        }

        private void Show(int code, string kicker, string heading, string statusName, string logResult, string copy)
        {
            Code = code;
            Kicker = kicker;
            Heading = heading;
            StatusName = statusName;
            LogResult = logResult;
            Copy = copy;
        }
    }
}
