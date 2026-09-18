using _24_1444AdoteRonAdrian_Portfolio.AdminServices;
using System;
using System.Web;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminApi
{
    // GET ?q=&status=&page=&pageSize= : one page of the users table.
    public class Users : AdminHandler
    {
        protected override string Method
        {
            get { return "GET"; }
        }

        protected override void Handle(HttpContext context)
        {
            int pageSize = QueryInt(context, "pageSize", UserDirectory.DefaultPageSize);

            // Only the sizes the page offers, so a hand-written URL can't ask for the whole table at once.
            if (Array.IndexOf(UserDirectory.PageSizes, pageSize) < 0)
            {
                pageSize = UserDirectory.DefaultPageSize;
            }

            WriteJson(context, 200, UserDirectory.Search(
                context.Request.QueryString["q"],
                context.Request.QueryString["status"],
                QueryInt(context, "page", 1),
                pageSize));
        }
    }
}
