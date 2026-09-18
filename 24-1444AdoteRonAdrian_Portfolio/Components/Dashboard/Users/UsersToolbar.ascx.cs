using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using _24_1444AdoteRonAdrian_Portfolio.AdminServices;

namespace _24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Users
{
    public partial class UsersToolbar : System.Web.UI.UserControl
    {
        // The server cuts a longer search to this length, so the box stops there too.
        protected const int MaxQueryLength = UserDirectory.MaxQueryLength;
        protected const string ActiveStatus = AccountStatus.Active;
        protected const string InactiveStatus = AccountStatus.Inactive;
    }
}
