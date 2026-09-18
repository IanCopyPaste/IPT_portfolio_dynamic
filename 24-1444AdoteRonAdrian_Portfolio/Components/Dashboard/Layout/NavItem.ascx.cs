using _24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Shared;

namespace _24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Layout
{
    // One sidebar link: <dash:NavItem runat="server" View="users" Label="Users" IconName="users" />.
    public partial class NavItem : System.Web.UI.UserControl
    {
        // Matches the data-view of the section the link shows.
        public string View { get; set; }
        public string Label { get; set; }
        public string IconName { get; set; }

        // The view shown when the page opens without a #view in the URL.
        public bool IsDefault { get; set; }

        protected string IconMarkup
        {
            get { return Icon.Markup(IconName); }
        }
    }
}
