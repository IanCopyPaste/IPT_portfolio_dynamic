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
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["username"] == null && Session["user_id"] == null)
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
