namespace _24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Analytics
{
    // <dash:ChartCard runat="server" Chart="signups" Heading="..." Subheading="..." IsWide="true" />
    public partial class ChartCard : System.Web.UI.UserControl
    {
        // Which chart analytics.js draws in the card.
        public string Chart { get; set; }
        public string Heading { get; set; }
        public string Subheading { get; set; }

        // Spans two columns of the chart grid; for the time series, which needs the width.
        public bool IsWide { get; set; }
    }
}
