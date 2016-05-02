namespace TermProject
{
    public class Tweet
    {
        public string Text;
        public int Favs;
        public int Rts;

        public Tweet()
        {
            Text = null;
            Favs = 0;
            Rts = 0;
        }

        public Tweet(string text, int favs, int rts)
        {
            Text = text;
            Favs = favs;
           Rts = rts;
        }
    }
}