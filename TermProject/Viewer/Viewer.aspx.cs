using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.Security;
using System.Web.UI;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;
using NUnit.Framework.Constraints;

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

        public Tweet LatestTweet;
        public Tweet PopTweet;
        public string LatestText;
        public string LatestFavs;
        public string LastestRTs;
        public string PopText;
        public string PopFavs;
        public string PopRts;

        public string TweetsJsonKeys;
        public string TweetsJsonVals;

        public string HashJsonKeys;
        public string HashJsonVals;

        public string MentionsJsonKeys;
        public string MentionsJsonVals;

        public string FavsJsonKeys;
        public string FavsJsonVals;
        public string RtsJsonKeys;
        public string RtsJsonVals;
        public string CountJson;
        public string FavsJsonKeysAlt;
        public string FavsJsonValsAlt;
        public string RtsJsonKeysAlt;
        public string RtsJsonValsAlt;
        public string CountJsonAlt;

        public string AvgFavs;
        public string AvgRts;
        public string AvgMonth;
        public string AvgDay;

        public string HoursKeys;
        public string HoursVals;

        public string DaysKeys;
        public string DaysVals;

        public Dictionary<string, int> Tweets;

        protected void Page_Init(object sender, EventArgs e)
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

            LatestTweet = Crawler.GetLatestTweet(account);
            LatestText = LatestTweet.Text;
            LatestFavs = $"{LatestTweet.Favs:N0}";
            LastestRTs = $"{LatestTweet.Rts:N0}";

            PopTweet = Crawler.GetMostPopular(tweets);
            PopText = PopTweet.Text;
            PopFavs = $"{PopTweet.Favs:N0}";
            PopRts = $"{PopTweet.Rts:N0}";

            var tweetsDir = Crawler.OrderWithCutouff(Crawler.StatusToString(tweets), 10);
            TweetsJsonKeys = JsonConvert.SerializeObject(tweetsDir.Keys);
            TweetsJsonVals = JsonConvert.SerializeObject(tweetsDir.Values);

            var hashtagDir = Crawler.OrderWithCutouff(Crawler.HashtagToString(Crawler.GetHashtags(tweets)), 5);
            HashJsonKeys = JsonConvert.SerializeObject(hashtagDir.Keys);
            HashJsonVals = JsonConvert.SerializeObject(hashtagDir.Values);

            var mentionsDir = Crawler.OrderWithCutouff(Crawler.HashtagToString(Crawler.GetMensions(tweets)), 5);
            MentionsJsonKeys = JsonConvert.SerializeObject(mentionsDir.Keys);
            MentionsJsonVals = JsonConvert.SerializeObject(mentionsDir.Values);

            var favsDir = Crawler.GetFavsOverMonth(tweets);
            FavsJsonKeys = JsonConvert.SerializeObject(favsDir.MonthList);
            FavsJsonVals = JsonConvert.SerializeObject(favsDir.ValueList);

            var rtsDir = Crawler.GetRtsOverMonth(tweets);
            RtsJsonKeys = JsonConvert.SerializeObject(rtsDir.MonthList);
            RtsJsonVals = JsonConvert.SerializeObject(rtsDir.ValueList);
            CountJson = JsonConvert.SerializeObject(rtsDir.Count);

            var favsDirAlt = Crawler.GetFavsOverDay(tweets);
            FavsJsonKeysAlt = JsonConvert.SerializeObject(favsDirAlt.MonthList);
            FavsJsonValsAlt = JsonConvert.SerializeObject(favsDirAlt.ValueList);

            var rtsDirAlt = Crawler.GetRtsOverDay(tweets);
            RtsJsonKeysAlt = JsonConvert.SerializeObject(rtsDirAlt.MonthList);
            RtsJsonValsAlt = JsonConvert.SerializeObject(rtsDirAlt.ValueList);
            CountJsonAlt = JsonConvert.SerializeObject(rtsDirAlt.Count);

            AvgFavs = $"{Crawler.GetAverageFavs(tweets):N0}";
            AvgRts = $"{Crawler.GetAverageRt(tweets):N0}";
            AvgDay = rtsDir.TweetsPer(rtsDirAlt);
            AvgMonth = rtsDirAlt.TweetsPer(rtsDir);


            var hoursDir = Crawler.Order(Crawler.HoursToString(Crawler.GetTime(tweets, "hour")));
            HoursKeys = JsonConvert.SerializeObject(hoursDir.Keys);
            HoursVals = JsonConvert.SerializeObject(hoursDir.Values);

            var daysDiv = Crawler.Order(Crawler.DaysToString(Crawler.GetDayOfWeek(tweets)));
            DaysKeys = JsonConvert.SerializeObject(daysDiv.Keys);
            DaysVals = JsonConvert.SerializeObject(daysDiv.Values);
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