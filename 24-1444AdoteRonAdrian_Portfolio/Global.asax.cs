using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;

namespace _24_1444AdoteRonAdrian_Portfolio
{
    public class Global : HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
        }

        // Web.config's customErrors shows the visitor ErrorPage, which says nothing specific on
        // purpose, so this is the only record of what actually went wrong. A missing page is
        // ordinary traffic, not a fault, and isn't logged.
        void Application_Error(object sender, EventArgs e)
        {
            Exception error = Server.GetLastError();
            var http = error as HttpException;

            if (error == null || (http != null && http.GetHttpCode() == 404))
            {
                return;
            }

            System.Diagnostics.Trace.TraceError("Unhandled error on {0}: {1}", Request.RawUrl, error);
        }
    }
}
