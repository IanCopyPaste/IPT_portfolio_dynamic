using _24_1444AdoteRonAdrian_Portfolio.AdminServices;
using _24_1444AdoteRonAdrian_Portfolio.AdminServices.Models;
using System.Web;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminApi
{
    // GET ?id= : one account in full, for the Manage dialog.
    public class UserInfo : AdminHandler
    {
        protected override string Method
        {
            get { return "GET"; }
        }

        protected override void Handle(HttpContext context)
        {
            UserDetail user = UserDirectory.Find(QueryInt(context, "id", 0));

            if (user == null)
            {
                WriteError(context, 404, UserRequest.NotFoundMessage);
                return;
            }

            WriteJson(context, 200, user);
        }
    }
}
