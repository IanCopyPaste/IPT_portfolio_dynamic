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
        // Single source of truth for the navbar brand text — swap here to change it everywhere it's used.
        public const string SiteBrandName = "Ron Adrian";

        // Home hero heading — kept separate from SiteBrandName since wireframes show them differing.
        public const string HomeHeadingName = "Ron Adrian Adote";
        protected void Page_Load(object sender, EventArgs e)
        {

        }
    }
}
