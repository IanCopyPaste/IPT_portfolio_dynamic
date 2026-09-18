using _24_1444AdoteRonAdrian_Portfolio.AdminServices;

namespace _24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Settings
{
    public partial class AccountCard : System.Web.UI.UserControl
    {
        protected const string PortfolioUrl = "/ContentPage.aspx";

        private SignedInAdmin currentAdmin;

        protected SignedInAdmin CurrentAdmin
        {
            get { return currentAdmin ?? (currentAdmin = SignedInAdmin.From(Session)); }
        }
    }
}
