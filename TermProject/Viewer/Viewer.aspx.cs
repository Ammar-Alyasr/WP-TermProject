using System;
using System.Collections.Generic;
using System.Text;
using System.Web.Security;
using System.Web.UI;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;

namespace TermProject.Viewer
{
    public partial class Viewer : Page
    {
        private static readonly Crawler Crawler = new Crawler();

        public string ProfileUrl;
        public string Name;
        public string BannerUrl;

        public string TweetCount;
        public string FollwersCount;
        public string FollowingCount;
        public string Date;

        public Tweet latestTweet;
        public Tweet popTweet;
        public string latestText;
        public int latestFavs;
        public int lastestRTs;
        public string popText;
        public int popFavs;
        public int PopRts;

        public string tweetsJson;
        public string tweetsJsonKeys;
        public string tweetsJsonVals;

        public string hashJson;
        public string hashJsonKeys;
        public string hashJsonVals;

        public string mentionsJson;
        public string mentionsJsonKeys;
        public string mentionsJsonVals;

        public Dictionary<string, int> Tweets;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsAdmin()) manage.Visible = false;

            var name = GetUserTwitter(User.Identity.Name);
            var account = Crawler.GetProfileFor(name);
            var tweets = Crawler.GetUserTimeline(name, 1000);

            ProfileUrl = Crawler.GetUserProfileImage(account);
            Name = Crawler.GetUserName(account);
            BannerUrl = Crawler.GetBannerUrl(account);

            TweetCount = Crawler.GetTweetsCount(account);
            FollwersCount = Crawler.GetFollowerCount(account);
            FollowingCount = Crawler.GetFollowingCount(account);
            Date = Crawler.GetCreateDate(account);

            latestTweet = Crawler.GetLatestTweet(account);
            latestText = latestTweet.Text;
            latestFavs = latestTweet.Favs;
            lastestRTs = latestTweet.Rts;
            popTweet = Crawler.GetMostPopular(tweets);
            popText = popTweet.Text;
            popFavs = popTweet.Favs;
            PopRts = popTweet.Rts;

            var tweetsDir = Crawler.OrderWithCutouff(Crawler.StatusToString(tweets), 10);
            tweetsJson = JsonConvert.SerializeObject(tweetsDir);
            tweetsJsonKeys = JsonConvert.SerializeObject(tweetsDir.Keys);
            tweetsJsonVals = JsonConvert.SerializeObject(tweetsDir.Values);

            var hashtagDir = Crawler.OrderWithCutouff(Crawler.HashtagToString(Crawler.GetHashtags(tweets)), 5);
            hashJson = JsonConvert.SerializeObject(hashtagDir);
            hashJsonKeys = JsonConvert.SerializeObject(hashtagDir.Keys);
            hashJsonVals = JsonConvert.SerializeObject(hashtagDir.Values);

            var mentionsDir = Crawler.OrderWithCutouff(Crawler.HashtagToString(Crawler.GetMensions(tweets)), 5);
            mentionsJson = JsonConvert.SerializeObject(mentionsDir);
            mentionsJsonKeys = JsonConvert.SerializeObject(mentionsDir.Keys);
            mentionsJsonVals = JsonConvert.SerializeObject(mentionsDir.Values);
        }

        public string GetUserTwitter(string name)
        {
            MySqlConnection connection = new MySqlConnection
                ("server=us-cdbr-iron-east-03.cleardb.net;database=heroku_6610293399c822c;uid=baaa895c37202a;pwd=906311ad");

            try
            {
                connection.Open();

                StringBuilder builder = new StringBuilder();
                builder.Append("select twitter from accounts where username = \'");
                builder.Append(name);
                builder.Append("\'");

                MySqlCommand command = new MySqlCommand(builder.ToString(), connection);
                object twitter = command.ExecuteScalar();
                if (twitter is DBNull) return null;

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

        private bool IsAdmin()
        {
            return User.IsInRole("admin");
        }

        protected void LogOut(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
            FormsAuthentication.RedirectToLoginPage();
        }
    }
}