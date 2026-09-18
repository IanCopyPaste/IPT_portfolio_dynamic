using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using _24_1444AdoteRonAdrian_Portfolio.AdminServices;
using System.Web;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminApi
{
    // POST { id, status } : activates or deactivates an account.
    public class UserStatus : AdminHandler
    {
        protected override string Method
        {
            get { return "POST"; }
        }

        protected override void Handle(HttpContext context)
        {
            UserRequest body = ReadBody<UserRequest>(context);

            if (!AccountStatus.IsValid(body.Status))
            {
                WriteError(context, 400, "Status must be active or inactive.");
                return;
            }

            if (!UserDirectory.SetStatus(body.Id, body.Status))
            {
                WriteError(context, 404, UserRequest.NotFoundMessage);
                return;
            }

            WriteJson(context, 200, new { id = body.Id, status = body.Status });
        }
    }
}
