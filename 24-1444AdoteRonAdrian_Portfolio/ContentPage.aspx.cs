using _24_1444AdoteRonAdrian_Portfolio.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace _24_1444AdoteRonAdrian_Portfolio
{
    public partial class ContentPage : System.Web.UI.Page
    {
        public const string SiteBrandName = "IAN ADOTE";

        public static readonly DateTime BirthDate = new DateTime(2006, 4, 16);
        public static int Age => DateTime.Today.Year - BirthDate.Year -
        (DateTime.Today.DayOfYear < BirthDate.DayOfYear ? 1 : 0);


        public const string HomeHeadingName = "Ron Adrian Adote";

        // Shown when the account button is hovered. A session signed in before the full name was
        // stored has only the username, so that stands in until the user signs in again.
        protected string AccountName =>
            Session[UserSession.FullNameKey] as string ?? Session[UserSession.UsernameKey] as string ?? "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!UserSession.IsSignedIn(Session))
            {
                Response.StatusCode = 401;
                Response.Redirect("~/ForbiddenPage.aspx");
                Response.End();
                return;
            }

            //string script = "alert('" + Session["username"] + "')";
            //ClientScript.RegisterStartupScript(this.GetType(), "alertKey", script, true);

        }
    }
}
