using System;
using System.Text;
using System.Web.UI;
using MySql.Data.MySqlClient;

namespace TermProject
{
    public partial class Viewer : Page
    {
        private static readonly Crawler Crawler = new Crawler();

        public string ProfileUrl;
        public string Name;
        public string BannerUrl;

        protected void Page_Load(object sender, EventArgs e)
        {
            ProfileUrl = Crawler.GetUserProfileImage(GetUserTwitter(User.Identity.Name));
            Name = Crawler.GetUserName(GetUserTwitter(User.Identity.Name));
            BannerUrl = Crawler.GetBannerURL(GetUserTwitter(User.Identity.Name));
        }

        public string GetUserTwitter(string name)
        {
            MySqlConnection connection = new MySqlConnection
                ("server=us-cdbr-iron-east-03.cleardb.net;database=heroku_6610293399c822c;uid=baaa895c37202a;pwd=906311ad");

            try
            {
                connection.Open();

                StringBuilder builder = new StringBuilder();
                builder.Append("select twitter from accounts " +
                    "where username = \'");
                builder.Append(name);
                builder.Append("\'");

                MySqlCommand command = new MySqlCommand(builder.ToString(),
                    connection);

                object twitter = command.ExecuteScalar();

                if (twitter is DBNull)
                    return null;

                return (string)twitter;
            }
            catch (MySqlException)
            {
                return null;
            }
            finally
            {
                connection.Close();
            }
        }

        protected void btn_serach_Click(object sender, EventArgs e)
        {
            var tweets = Crawler.GetUserTimeline(tb_input.Text, int.Parse(tb_count.Text));
            var list = Crawler.OrderWithCutouff(Crawler.StatusToString(tweets), 10);

            mydiv.InnerHtml = Crawler.PrintList(list);
        }
    }
}