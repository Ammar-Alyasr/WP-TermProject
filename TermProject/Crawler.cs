using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using TweetSharp;

namespace TermProject
{
    public class Crawler
    {
        private TwitterService _service;

        public Crawler()
        {
            Authenticate();
        }

        // authenticates the crawler for searching
        public void Authenticate()
        {
            const string token = "589683699-2Lch4rjFMFv7CCLznoTUrlj5eMAWihEhYazRHl5P";
            const string tokenSecret = "YIZNZ0PbqUaRZfzKjrqcsj2SnIcF4vnhEI2WPf4vKbOMu";
            const string consumerKey = "JlhAPdbEXK7EShHW2nbLSMb9o";
            const string consumerSecret = "mHW5x5a3HZ2n0S1PMXVBomk4wJZsHrEvjqmc8eag29qP9vFQll";

            _service = new TwitterService(consumerKey, consumerSecret);
            _service.AuthenticateWith(token, tokenSecret);
        }

        /*------------------------------------------------------------------------------------------------------------------------
         * 
         *  Get tweets
         * 
         -----------------------------------------------------------------------------------------------------------------------*/

        // returns tweets based on a term
        public IEnumerable<TwitterStatus> GetSearch(string query, int count)
        {
            var options = new SearchOptions
            {
                Q = query,
                Count = count,
                Lang = "en"
            };
            var tweets = _service.Search(options);
            return tweets.Statuses;
        }

        // returns tweets based on a user's timeline
        public IEnumerable<TwitterStatus> GetUserTimeline(string name, int count)
        {
            var options = new ListTweetsOnUserTimelineOptions()
            {
                ScreenName = name,
                Count = count
            };
            var tweets = _service.ListTweetsOnUserTimeline(options);
            return tweets;
        }

        /*------------------------------------------------------------------------------------------------------------------------
         * 
         *  Get tweet info
         * 
         -----------------------------------------------------------------------------------------------------------------------*/

        // returns a list of hashtags from a list of tweets
        public List<Match> GetHashtags(IEnumerable<TwitterStatus> tweets)
        {
            Regex pattern = new Regex(@"#\w+");
            List<MatchCollection> matches = tweets.Select(tweet => pattern.Matches(tweet.Text)).ToList();
            return matches.SelectMany(match => match.Cast<Match>()).ToList();
        }

        // returns a list of mensions from a list of tweets
        public List<Match> GetMensions(IEnumerable<TwitterStatus> rawTweet)
        {
            Regex pattern = new Regex(@"@\w+");
            List<MatchCollection> matches = rawTweet.Select(tweet => pattern.Matches(tweet.Text)).ToList();
            return matches.SelectMany(match => match.Cast<Match>()).ToList();
        }

        // returns list of time as integer when a tweet was posted (type = time granularity)
        public List<DayOfWeek> GetDayOfWeek(IEnumerable<TwitterStatus> tweets)
        {
            return tweets.Select(tweet => tweet.CreatedDate.DayOfWeek).ToList();
        }

        public List<int> GetTime(IEnumerable<TwitterStatus> tweets, string type)
        {
            switch (type)
            {
                case "hour":
                    return tweets.Select(tweet => tweet.CreatedDate.Hour).ToList();
                case "month":
                    return tweets.Select(tweet => tweet.CreatedDate.Month).ToList();
                case "year":
                    return tweets.Select(tweet => tweet.CreatedDate.Year).ToList();
                case "dayofyear":
                    return tweets.Select(tweet => tweet.CreatedDate.DayOfYear).ToList();
                default:
                    return null;
            }
        }

        // TODO
        // still working on this one. It returns location of all a user's followers
        public void GetFollowerLocations(string name)
        {
            var options = new ListFollowersOptions
            {
                ScreenName = name,
                Count = 100,
                SkipStatus = false,
                IncludeUserEntities = true
            };

            var usersfollowers = _service.ListFollowers(options);
            string str = "";
            foreach (var follower in usersfollowers)
            {
                if (string.IsNullOrEmpty(follower.Location) || follower.Location.Contains("?")) continue;
                str += follower.Location + "\n";
            }
            Console.WriteLine(str);
        }

        // returns the most popular tweet with fav and rt values
        public string GetMostPopular(IEnumerable<TwitterStatus> tweets)
        {
            int value = 0;
            int index = 0;
            var tweet = tweets as IList<TwitterStatus> ?? tweets.ToList();

            for (int i = 0; i < tweet.Count; i++)
            {
                int temp = tweet.ElementAt(i).FavoriteCount + tweet.ElementAt(i).RetweetCount;
                if (temp <= value) continue;
                value = temp;
                index = i;
            }

            return $"{tweet[index].Text}\n{tweet[index].FavoriteCount} Favorites, {tweet[index].RetweetCount} Retweets";
        }

        /*------------------------------------------------------------------------------------------------------------------------
         * 
         *  Convert to string
         * 
         -----------------------------------------------------------------------------------------------------------------------*/

        // converts a list of tweets into a giant string of them
        public string StatusToString(IEnumerable<TwitterStatus> tweets)
        {
            return tweets.Aggregate("", (current, tweet) => current + ParseText(tweet.Text));
        }

        // converts a list of hastags into a giant string of them
        public string HashtagToString(List<Match> hastags)
        {
            return hastags.Aggregate("", (current, hashtag) => current + hashtag.ToString() + " ");
        }

        // converts a list of days into a giant string of them
        public string DaysToString(List<DayOfWeek> days)
        {
            return days.Aggregate("", (current, day) => current + (day + " "));
        }

        // converts a list of hours into a giant string of them
        public string HoursToString(List<int> hours)
        {
            return hours.Aggregate("", (current, hour) => current + (hour + " "));
        }

        /*------------------------------------------------------------------------------------------------------------------------
         * 
         *  Order results
         * 
         -----------------------------------------------------------------------------------------------------------------------*/


        // orders the words by count (no count cutouff)
        public Dictionary<string, int> Order(string tweets)
        {
            Dictionary<string, int> dictionary = new Dictionary<string, int>();
            string[] words = tweets.Replace(",", "").Replace("  ", " ").Split(' ');
            foreach (string word in words)
            {
                if (word == "") continue; //ignore the null that kept appearing
                if (!dictionary.ContainsKey(word)) dictionary.Add(word, 1);
                else dictionary[word]++;
            }
            var temp = dictionary.OrderByDescending(ac => ac.Value);
            return temp.ToDictionary(t => t.Key, t => t.Value);
        }

        // orders the words by count only returning where count > cutoff
        public Dictionary<string, int> OrderWithCutouff(string tweets, int cutoff)
        {
            Dictionary<string, int> dictionary = new Dictionary<string, int>();
            string[] words = tweets.Replace(",", "").Replace("  ", " ").Split(' ');
            foreach (string word in words)
            {
                if (word == "") continue; //ignore the null that kept appearing
                if (!dictionary.ContainsKey(word)) dictionary.Add(word, 1);
                else dictionary[word]++;
            }
            var keysToRemove = dictionary.Where(kvp => kvp.Value == cutoff) // <--- value here is cutoff for word freq.
                .Select(kvp => kvp.Key)
                .ToArray();

            foreach (var key in keysToRemove)
            {
                dictionary.Remove(key);
            }
            var list = dictionary.OrderByDescending(ac => ac.Value);
            return list.ToDictionary(t => t.Key, t => t.Value);
        }

        public string PrintList(Dictionary<string, int> list)
        {
            string str = "";
            foreach (var value in list)
            {
                str += value + "<br />";
            }
            return str;
        }

        /*------------------------------------------------------------------------------------------------------------------------
         * 
         *  Misc Functionsresults
         * 
         -----------------------------------------------------------------------------------------------------------------------*/

        // returns a tweet without any of the twitter jargin
        private string ParseText(string tweets)
        {
            Regex link = new Regex(@"http(s)?://([\w+?\.\w+])+([a-zA-Z0-9\~\!\@\#\$\%\^\&amp;\*\(\)_\-\=\+\\\/\?\.\:\;\'\,]*)?");
            Regex screenName = new Regex(@"@\w+");
            Regex hashTag = new Regex(@"#\w+");
            Regex numbers = new Regex(@"[\d-]");

            string rawText = link.Replace(tweets, string.Empty);
            rawText = screenName.Replace(rawText, string.Empty);
            rawText = hashTag.Replace(rawText, string.Empty);
            rawText = Regex.Replace(rawText, "[^0-9A-Za-z ,]", " "); //removes special chars
            rawText = Regex.Replace(rawText, @"\s+", " ");  // removes extra spaces
            rawText = numbers.Replace(rawText, string.Empty).ToLower(); // removes numbers and converts to all lowercase

            return rawText;
        }

    }
}