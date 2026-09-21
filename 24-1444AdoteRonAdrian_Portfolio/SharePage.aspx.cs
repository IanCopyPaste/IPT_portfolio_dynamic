using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using System;

namespace _24_1444AdoteRonAdrian_Portfolio
{
    // The public copy of one account's portfolio, reached by the link its owner makes on
    // ProfilePage. No sign-in: the token in the query string is the whole of the access check, and
    // the page is read-only, so the worst a leaked link shows is what the owner chose to publish.
    public partial class SharePage : System.Web.UI.Page
    {
        public const string SiteBrandName = ContentPage.SiteBrandName;

        // Null for a link that leads nowhere, which is what the markup switches on.
        protected ProfileContent Owner;

        protected bool Found => Owner != null;

        protected string OwnerName => Owner.FullName;

        protected void Page_Load(object sender, EventArgs e)
        {
            int? userId = ShareLinks.Find(Request.QueryString[ShareLinks.TokenQuery]);
            Owner = userId == null ? null : ProfileStore.Get(userId.Value);

            portfolio.Visible = Found;

            if (Found)
            {
                portfolio.Owner = Owner;
                portfolio.Limits = ProfileLimits.Get();
            }
            else
            {
                Response.StatusCode = 404;
                // Without this, IIS can swap the page for its own generic 404 screen.
                Response.TrySkipIisCustomErrors = true;
            }
        }
    }
}
