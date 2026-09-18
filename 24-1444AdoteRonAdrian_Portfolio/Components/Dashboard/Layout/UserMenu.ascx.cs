using _24_1444AdoteRonAdrian_Portfolio.AdminServices;
using _24_1444AdoteRonAdrian_Portfolio.Security;

namespace _24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Layout
{
    public partial class UserMenu : System.Web.UI.UserControl
    {
        protected const string LogoutUrl = "/AdminApi/Logout.ashx";
        protected const string CsrfField = AntiForgery.FormField;

        private SignedInAdmin admin;

        protected SignedInAdmin CurrentAdmin
        {
            get { return admin ?? (admin = SignedInAdmin.From(Session)); }
        }

        protected string CsrfToken
        {
            get { return AntiForgery.Token(Session); }
        }
    }
}
