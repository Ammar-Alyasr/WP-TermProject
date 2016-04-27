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

        // returns tweets based on a term up to a given value
        public IEnumerable<TwitterStatus> GetSearchResults(string query, int toValue)
        {
            List<TwitterStatus> allTweets = new List<TwitterStatus>();
            string maxid = "1000000000000"; // dummy value
            int tweetcount = 0;


            if (maxid != null)
            {
                var tweets_search = _service.Search(new SearchOptions { Q = query, Count = Convert.ToInt32(toValue) });
                List<TwitterStatus> resultList = new List<TwitterStatus>(tweets_search.Statuses);
                maxid = resultList.Last().IdStr;
                foreach (var tweet in tweets_search.Statuses)
                {
                    try
                    {
                        allTweets.Add(tweet);
                        tweetcount++;
                    }
                    catch { }
                }

                while (maxid != null && tweetcount < Convert.ToInt32(toValue))
                {
                    maxid = resultList.Last().IdStr;
                    tweets_search = _service.Search(new SearchOptions { Q = query, Count = Convert.ToInt32(toValue), MaxId = Convert.ToInt64(maxid) });
                    resultList = new List<TwitterStatus>(tweets_search.Statuses);
                    foreach (var tweet in tweets_search.Statuses)
                    {
                        try
                        {
                            allTweets.Add(tweet);
                            tweetcount++;
                        }
                        catch { }
                    }
                }

            }

            return allTweets;
        }

        // returns tweets based on a user's timeline up to a given value
        public List<TwitterStatus> GetUserTimeline(string name, int toValue)
        {
            List<TwitterStatus> allTweets = new List<TwitterStatus>();
            int tweetcount = 0;

            var tweets = _service.ListTweetsOnUserTimeline(new ListTweetsOnUserTimelineOptions
            {
                ScreenName = name,
                Count = toValue
            });
            List<TwitterStatus> resultList = new List<TwitterStatus>(tweets);
            var maxid = resultList.Last().IdStr;
            foreach (var tweet in tweets)
            {
                allTweets.Add(tweet);
                tweetcount++;
            }

            while (maxid != null && tweetcount < toValue)
            {
                maxid = resultList.Last().IdStr;
                tweets = _service.ListTweetsOnUserTimeline(new ListTweetsOnUserTimelineOptions
                {
                    ScreenName = name,
                    Count = toValue,
                    MaxId = Convert.ToInt64(maxid)
                });
                resultList = new List<TwitterStatus>(tweets);
                foreach (var tweet in tweets)
                {
                    allTweets.Add(tweet);
                    tweetcount++;
                }
            }

            return allTweets;
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
        public string GetFollowerLocations(string name)
        {
            ListFollowersOptions options = new ListFollowersOptions
            {
                ScreenName = name,
                IncludeUserEntities = true,
                SkipStatus = false,
                Cursor = -1
            };
            var lstFollowers = new List<TwitterUser>();

            TwitterCursorList<TwitterUser> followers = _service.ListFollowers(options);

            if (followers == null)
            {
                //ignore
            }
            else
            {
                while (followers.NextCursor != null)
                {
                    options.Cursor = followers.NextCursor;
                    followers = _service.ListFollowers(options);


                    if (followers == null)
                    {
                        //ignore
                    }
                    else
                    {
                        lstFollowers.AddRange(followers);
                    }

                    if (followers?.NextCursor != null && followers.NextCursor != 0)
                    {
                        options.Cursor = followers.NextCursor;
                        followers = _service.ListFollowers(options);
                    }
                    else break;
                }
            }

            string str = "";
            int count = 0;
            foreach (var follower in lstFollowers)
            {
                count++;
                str += count + ": " + follower.ScreenName + "<br/>";
            }

            return str;
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