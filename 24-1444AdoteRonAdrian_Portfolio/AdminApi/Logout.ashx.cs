using _24_1444AdoteRonAdrian_Portfolio.Security;
using System;
using System.Web;
using System.Web.SessionState;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminApi
{
    // POST from the user menu's log-out form. Not an AdminHandler: this answers a plain form post, so
    // it always ends in a redirect rather than JSON. The token keeps another site from signing the
    // admin out; a request without a valid one is sent back without signing anyone out, and Admin.aspx
    // forwards a still-signed-in admin to the dashboard.
    public class Logout : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable
        {
            get { return false; }
        }

        public void ProcessRequest(HttpContext context)
        {
            bool verified = string.Equals(context.Request.HttpMethod, "POST", StringComparison.OrdinalIgnoreCase)
                && AntiForgery.IsValid(context.Session, context.Request.Form[AntiForgery.FormField]);

            string target = "~/Admin.aspx";

            if (verified)
            {
                UserSession.SignOut(context.Session);
                target += "?" + _24_1444AdoteRonAdrian_Portfolio.Admin.SignedOutQuery + "=1";
            }

            context.Response.Redirect(target, false);
            context.ApplicationInstance.CompleteRequest();
        }
    }
}
