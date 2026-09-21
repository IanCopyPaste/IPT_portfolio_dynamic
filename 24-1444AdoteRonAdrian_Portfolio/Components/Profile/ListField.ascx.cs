using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using System.Collections.Generic;
using System.Linq;

namespace _24_1444AdoteRonAdrian_Portfolio.Components.Profile
{
    public partial class ListField : System.Web.UI.UserControl
    {
        public ListField()
        {
            Values = new List<string>();
            Errors = new List<string>();
        }

        // Set in the markup: the name every row's input posts under (and the prefix of their ids),
        // and the words the rows and the button are labelled with.
        public string FieldName { get; set; }
        public string Noun { get; set; }
        public string Plural { get; set; }
        public string Placeholder { get; set; }

        // Set by the page before it shows or reads anything: the admin's limit and the column width.
        public int Max { get; set; }
        public int MaxLength { get; set; }

        // The rows as drawn, with the message under each (null for none) at the same index.
        public List<string> Values { get; private set; }
        public List<string> Errors { get; private set; }

        public string CountError { get; private set; }

        public void Show(IEnumerable<string> values)
        {
            Values = values.ToList();
            Errors = Values.Select(value => (string)null).ToList();
            // Said as soon as the form opens, not only after a save is refused: an admin who lowered
            // the limit has left rows here that can no longer all be kept.
            CountError = ProfileRules.ListCountError(Values.Count, Max, Plural);
        }

        // Reads the rows back from the post and checks them, and keeps them to be drawn again if
        // the save is refused. Rows left blank are dropped rather than reported: an empty row is
        // simply one the user added and didn't use.
        public bool Read()
        {
            Values = Posted();
            Errors = Values.Select(value => ProfileRules.TextError(value, MaxLength)).ToList();
            CountError = ProfileRules.ListCountError(Values.Count, Max, Plural);

            return CountError == null && Errors.All(error => error == null);
        }

        // For a post-back that isn't a save, such as the share buttons: the rows aren't in view state,
        // so without this they would be drawn empty, and the user's next Save would wipe the list.
        // Nothing is checked, since nothing is being saved.
        public void Keep()
        {
            Show(Posted());
        }

        private List<string> Posted()
        {
            string[] posted = Request.Form.GetValues(FieldName) ?? new string[0];
            return posted.Select(value => value.Trim()).Where(value => value.Length > 0).ToList();
        }
    }
}
