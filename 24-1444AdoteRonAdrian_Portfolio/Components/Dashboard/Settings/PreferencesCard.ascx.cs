using _24_1444AdoteRonAdrian_Portfolio.AdminServices;
using System.Collections.Generic;

namespace _24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Settings
{
    public partial class PreferencesCard : System.Web.UI.UserControl
    {
        protected IEnumerable<int> PageSizes
        {
            get { return UserDirectory.PageSizes; }
        }
    }
}
