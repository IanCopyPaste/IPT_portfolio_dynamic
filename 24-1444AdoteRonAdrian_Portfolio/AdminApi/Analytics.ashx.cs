using _24_1444AdoteRonAdrian_Portfolio.AdminServices;
using System.Web;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminApi
{
    // GET: the figures for the Analytics view.
    public class Analytics : AdminHandler
    {
        protected override string Method
        {
            get { return "GET"; }
        }

        protected override void Handle(HttpContext context)
        {
            WriteJson(context, 200, AnalyticsReport.Build());
        }
    }
}
