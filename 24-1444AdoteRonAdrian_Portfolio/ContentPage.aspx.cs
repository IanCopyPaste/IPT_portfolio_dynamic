using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using _24_1444AdoteRonAdrian_Portfolio.Security;
using System;

namespace _24_1444AdoteRonAdrian_Portfolio
{
    public partial class ContentPage : System.Web.UI.Page
    {
        // The site's own name, on the sign-in, sign-up and 403 screens and in the dashboard footer,
        // where there is no user to name. The portfolio itself is branded with its owner instead.
        public const string SiteBrandName = "USER";

        // Stands in for any portfolio field the user hasn't filled in yet. ContentPage is one
        // account's page, so a brand-new account sees this in most of it until they visit
        // ProfilePage; the cp-unset class greys each one out so a filled page is obvious at a glance.
        public const string UnsetText = "Not set yet";

        // Filled in Page_Load, which runs before the markup is rendered.
        protected ProfileContent Owner;

        protected string OwnerName => Owner.FullName;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!UserSession.IsSignedIn(Session))
            {
                Response.StatusCode = 401;
                Response.Redirect("~/ForbiddenPage.aspx");
                Response.End();
                return;
            }

            int? userId = UserSession.UserId(Session);
            Owner = userId == null || !AccountStatus.IsActive(userId.Value) ? null : ProfileStore.Get(userId.Value);

            // No row means the account was deleted while this session was open, and an inactive one
            // was deactivated by an admin; either way the session is stale and there is no portfolio
            // to draw.
            if (Owner == null)
            {
                UserSession.SignOut(Session);
                Response.Redirect("~/LoginPage.aspx");
                Response.End();
            }

            portfolio.Owner = Owner;
            portfolio.Limits = ProfileLimits.Get();
        }
    }
}
