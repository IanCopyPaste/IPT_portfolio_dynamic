namespace _24_1444AdoteRonAdrian_Portfolio.AdminServices.Models
{
    // A labelled count: one month, one sign-in window, one profile field.
    public class CountBucket
    {
        public string Key { get; set; }
        public string Label { get; set; }
        public int Count { get; set; }

        public CountBucket(string key, string label, int count)
        {
            Key = key;
            Label = label;
            Count = count;
        }
    }
}
