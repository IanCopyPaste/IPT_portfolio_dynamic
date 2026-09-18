using _24_1444AdoteRonAdrian_Portfolio.Security;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System;
using System.Diagnostics;
using System.IO;
using System.Web;
using System.Web.SessionState;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminApi
{
    // Base for the dashboard's JSON endpoints. Every check that must never be forgotten lives here
    // rather than in each endpoint: signed in as an admin, the right HTTP method, and on a POST the
    // anti-forgery header. An endpoint only implements Handle.
    public abstract class AdminHandler : IHttpHandler, IRequiresSessionState
    {
        private static readonly JsonSerializerSettings JsonSettings = new JsonSerializerSettings
        {
            ContractResolver = new CamelCasePropertyNamesContractResolver(),
            DateTimeZoneHandling = DateTimeZoneHandling.Utc
        };

        public bool IsReusable
        {
            get { return false; }
        }

        protected abstract string Method { get; }

        protected abstract void Handle(HttpContext context);

        public void ProcessRequest(HttpContext context)
        {
            HttpResponse response = context.Response;
            // Account data must not be kept by the browser or a proxy after the admin signs out.
            response.Cache.SetCacheability(HttpCacheability.NoCache);
            response.Cache.SetNoStore();
            response.AddHeader("X-Content-Type-Options", "nosniff");

            // 401, not a redirect: the caller is script, and it sends the admin to the sign-in page
            // itself when it sees this.
            if (!UserSession.IsAdmin(context.Session))
            {
                WriteError(context, 401, "Your session has ended. Sign in again.");
                return;
            }

            if (!string.Equals(context.Request.HttpMethod, Method, StringComparison.OrdinalIgnoreCase))
            {
                response.AddHeader("Allow", Method);
                WriteError(context, 405, "Method not allowed.");
                return;
            }

            if (Method == "POST" && !AntiForgery.IsValid(context.Session, context.Request.Headers[AntiForgery.HeaderName]))
            {
                WriteError(context, 403, "This request could not be verified. Reload the page and try again.");
                return;
            }

            try
            {
                Handle(context);
            }
            catch (JsonException)
            {
                WriteError(context, 400, "The request was not valid.");
            }
            catch (Exception ex)
            {
                // The details go to the trace, not to the browser.
                Trace.TraceError("Admin API {0} failed: {1}", context.Request.Path, ex);
                WriteError(context, 500, "Something went wrong on the server. Try again.");
            }
        }

        protected static int AdminId(HttpContext context)
        {
            return UserSession.UserId(context.Session).Value;
        }

        protected static T ReadBody<T>(HttpContext context) where T : class, new()
        {
            using (var reader = new StreamReader(context.Request.InputStream))
            {
                return JsonConvert.DeserializeObject<T>(reader.ReadToEnd(), JsonSettings) ?? new T();
            }
        }

        protected static int QueryInt(HttpContext context, string name, int fallback)
        {
            int value;
            return int.TryParse(context.Request.QueryString[name], out value) ? value : fallback;
        }

        protected static void WriteJson(HttpContext context, int status, object body)
        {
            context.Response.StatusCode = status;
            // Otherwise IIS swaps an error's JSON body for its own HTML error page.
            context.Response.TrySkipIisCustomErrors = true;
            context.Response.ContentType = "application/json";
            context.Response.Write(JsonConvert.SerializeObject(body, JsonSettings));
        }

        protected static void WriteError(HttpContext context, int status, string message)
        {
            WriteJson(context, status, new { error = message });
        }
    }
}
