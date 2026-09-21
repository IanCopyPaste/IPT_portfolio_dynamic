using _24_1444AdoteRonAdrian_Portfolio.Accounts;

namespace _24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Settings
{
    public partial class LimitsCard : System.Web.UI.UserControl
    {
        // ProfileLimits' range, which the server applies, so the form's own checks agree with it.
        protected const int Min = ProfileLimits.Min;
        protected const int Max = ProfileLimits.Max;

        // Read once per render: the inputs open on the values saved now.
        private ProfileLimits current;

        protected ProfileLimits Current
        {
            get { return current ?? (current = ProfileLimits.Get()); }
        }
    }
}
