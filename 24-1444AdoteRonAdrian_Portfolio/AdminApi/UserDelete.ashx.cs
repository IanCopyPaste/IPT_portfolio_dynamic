using _24_1444AdoteRonAdrian_Portfolio.AdminServices;
using System.Web;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminApi
{
    // POST { id } : permanently deletes an account.
    public class UserDelete : AdminHandler
    {
        protected override string Method
        {
            get { return "POST"; }
        }

        protected override void Handle(HttpContext context)
        {
            UserRequest body = ReadBody<UserRequest>(context);

            if (!UserDirectory.Delete(body.Id))
            {
                WriteError(context, 404, UserRequest.NotFoundMessage);
                return;
            }

            WriteJson(context, 200, new { id = body.Id });
        }
    }
}
