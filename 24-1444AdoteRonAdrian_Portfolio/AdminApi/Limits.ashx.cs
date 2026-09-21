using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using System.Collections.Generic;
using System.Web;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminApi
{
    // POST { maxHobbies, maxSkills } : how many hobbies and skills each account may list on its
    // profile. Both are sent every time, so a save never leaves one half-changed.
    public class Limits : AdminHandler
    {
        // Nullable so a field left out of the JSON is reported rather than read as zero.
        public class LimitsRequest
        {
            public int? MaxHobbies { get; set; }
            public int? MaxSkills { get; set; }
        }

        protected override string Method
        {
            get { return "POST"; }
        }

        protected override void Handle(HttpContext context)
        {
            LimitsRequest body = ReadBody<LimitsRequest>(context);
            var errors = new Dictionary<string, string>();

            AddIf(errors, "maxHobbies", ProfileLimits.Error(body.MaxHobbies));
            AddIf(errors, "maxSkills", ProfileLimits.Error(body.MaxSkills));

            if (errors.Count > 0)
            {
                WriteJson(context, 400, new { error = "Fix the highlighted fields and try again.", fields = errors });
                return;
            }

            var limits = new ProfileLimits(body.MaxHobbies.Value, body.MaxSkills.Value);
            ProfileLimits.Save(limits);

            WriteJson(context, 200, new { maxHobbies = limits.Hobbies, maxSkills = limits.Skills });
        }

        private static void AddIf(Dictionary<string, string> errors, string field, string message)
        {
            if (message != null)
            {
                errors[field] = message;
            }
        }
    }
}
