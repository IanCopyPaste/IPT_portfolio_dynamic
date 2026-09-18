using _24_1444AdoteRonAdrian_Portfolio.AdminServices;
using System.Collections.Generic;

namespace _24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Users
{
    public partial class UsersPagination : System.Web.UI.UserControl
    {
        // The sizes the Users endpoint accepts, so the list can't offer one it would refuse.
        protected IEnumerable<int> PageSizes
        {
            get { return UserDirectory.PageSizes; }
        }

        protected const int DefaultPageSize = UserDirectory.DefaultPageSize;
    }
}
