using _24_1444AdoteRonAdrian_Portfolio.AdminServices;
using System.Collections.Generic;
using System.Web;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminApi
{
    // POST { currentPassword, newPassword, confirmPassword } : the signed-in admin's own password.
    public class Password : AdminHandler
    {
        public class PasswordRequest
        {
            public string CurrentPassword { get; set; }
            public string NewPassword { get; set; }
            public string ConfirmPassword { get; set; }
        }

        protected override string Method
        {
            get { return "POST"; }
        }

        protected override void Handle(HttpContext context)
        {
            PasswordRequest body = ReadBody<PasswordRequest>(context);
            Dictionary<string, string> errors = AdminPassword.Change(
                AdminId(context), body.CurrentPassword, body.NewPassword, body.ConfirmPassword);

            if (errors.Count > 0)
            {
                WriteJson(context, 400, new { error = "Fix the highlighted fields and try again.", fields = errors });
                return;
            }

            WriteJson(context, 200, new { ok = true });
        }
    }
}
