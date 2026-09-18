using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using _24_1444AdoteRonAdrian_Portfolio.Security;

namespace _24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Settings
{
    public partial class PasswordCard : System.Web.UI.UserControl
    {
        // AccountRules' limits, which the server applies, so the form's own checks agree with it.
        protected const int MinLength = AccountRules.PasswordMinLength;
        protected const int MaxLength = AccountRules.PasswordMaxLength;

        protected string Username
        {
            get { return Session[UserSession.UsernameKey] as string ?? ""; }
        }
    }
}
