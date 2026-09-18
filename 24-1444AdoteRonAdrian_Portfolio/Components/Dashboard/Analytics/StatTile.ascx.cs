using _24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Shared;

namespace _24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Analytics
{
    // <dash:StatTile runat="server" Metric="active" Label="Active accounts" IconName="check-circle" />
    public partial class StatTile : System.Web.UI.UserControl
    {
        // The key analytics.js fills the tile from.
        public string Metric { get; set; }
        public string Label { get; set; }
        public string IconName { get; set; }

        protected string IconMarkup
        {
            get { return Icon.Markup(IconName, 18); }
        }
    }
}
