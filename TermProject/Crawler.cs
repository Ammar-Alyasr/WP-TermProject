using System;
using System.Collections.Generic;
using System.Globalization;
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
            int tweetcount = 0;

            var tweetsSearch = _service.Search(new SearchOptions
            {
                Q = query,
                Count = toValue,
                IncludeEntities = false
            });
            List<TwitterStatus> resultList = new List<TwitterStatus>(tweetsSearch.Statuses);
            var maxid = resultList.Last().IdStr;
            foreach (var tweet in tweetsSearch.Statuses)
            {
                allTweets.Add(tweet);
                tweetcount++;

            }

            while (maxid != null && tweetcount < toValue)
            {
                maxid = resultList.Last().IdStr;
                tweetsSearch = _service.Search(new SearchOptions
                {
                    Q = query,
                    Count = toValue,
                    MaxId = Convert.ToInt64(maxid)
                });
                resultList = new List<TwitterStatus>(tweetsSearch.Statuses);
                foreach (var tweet in tweetsSearch.Statuses)
                {
                    allTweets.Add(tweet);
                    tweetcount++;
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
                Count = toValue,
                IncludeRts = false
            });
            var twitterStatuses = tweets as IList<TwitterStatus> ?? tweets.ToList();
            List<TwitterStatus> resultList = new List<TwitterStatus>(twitterStatuses);
            var maxid = resultList.Last().IdStr;
            foreach (var tweet in twitterStatuses)
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
                    MaxId = Convert.ToInt64(maxid),
                    IncludeRts = false
                });
                var collection = tweets as IList<TwitterStatus> ?? tweets.ToList();
                resultList = new List<TwitterStatus>(collection);
                foreach (var tweet in collection)
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
        public List<Match> GetMensions(IEnumerable<TwitterStatus> tweets)
        {
            Regex pattern = new Regex(@"@\w+");
            List<MatchCollection> matches = tweets.Select(tweet => pattern.Matches(tweet.Text)).ToList();
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

        // returns location of the first 1000 user's followers
        public List<string> GetFollowerLocations(string name)
        {
            List<string> followerLoc = new List<string>();
            var options = new ListFollowersOptions { ScreenName = name, Count = 200, Cursor = -1 };
            var followers = _service.ListFollowers(options);
            int iter = 0;
            while (followers.NextCursor != null && iter < 5)
            {
                followerLoc.AddRange(from user in followers where user.Location != string.Empty select user.Location);
                if (followers.NextCursor != null && followers.NextCursor != 0)
                {
                    options.Cursor = followers.NextCursor;
                    followers = _service.ListFollowers(options);
                    iter++;
                }
                else break;
            }
            return followerLoc;
        }

        public List<string> GetLocations(IEnumerable<TwitterStatus> tweets)
        {
            return (from tweet in tweets where tweet.Location != null select tweet.Place.FullName).ToList();
        }

        // returns the most popular tweet with fav and rt values
        public Tweet GetMostPopular(IEnumerable<TwitterStatus> tweets)
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
            Tweet popular = new Tweet(TweetToHtml(tweet[index].Text) + " (" + tweet[index].CreatedDate.ToShortDateString() + ")", tweet[index].FavoriteCount, tweet[index].RetweetCount);
            return popular;
        }

        public DataByTime GetFavsOverDay(IEnumerable<TwitterStatus> tweets)
        {
            var favsList = new List<int>();
            var dateList = new List<string>();
            var twitterStatuses = tweets as IList<TwitterStatus> ?? tweets.ToList();
            int day = twitterStatuses[0].CreatedDate.DayOfYear;
            int value = 0;
            var count = new List<int>();
            int val = 0;
            int year = twitterStatuses[0].CreatedDate.Year;
            foreach (var tweet in twitterStatuses)
            {
                if (tweet.CreatedDate.DayOfYear == day)
                {
                    val++;
                    value += tweet.FavoriteCount;
                }
                else
                {
                    count.Add(val);
                    val = 0;
                    dateList.Add(new DateTime(year, 1, 1).AddDays(day -1).ToShortDateString());
                    favsList.Add(value);
                    value = tweet.FavoriteCount;
                    day = tweet.CreatedDate.DayOfYear;
                }
            }
            dateList.Reverse();
            favsList.Reverse();
            count.Reverse();
            return new DataByTime(dateList, favsList, count);
        }

        public DataByTime GetRtsOverDay(IEnumerable<TwitterStatus> tweets)
        {
            var rtsList = new List<int>();
            var dateList = new List<string>();
            var twitterStatuses = tweets as IList<TwitterStatus> ?? tweets.ToList();
            int day = twitterStatuses[0].CreatedDate.DayOfYear;
            int value = 0;
            var count = new List<int>();
            int val = 0;
            int year = twitterStatuses[0].CreatedDate.Year;
            foreach (var tweet in twitterStatuses)
            {
                if (tweet.CreatedDate.DayOfYear == day)
                {
                    val++;
                    value += tweet.RetweetCount;
                }
                else
                {
                    count.Add(val);
                    val = 0;
                    dateList.Add(new DateTime(year, 1, 1).AddDays(day - 1).ToShortDateString());
                    rtsList.Add(value);
                    value = tweet.RetweetCount;
                    day = tweet.CreatedDate.DayOfYear;
                }
            }
            dateList.Reverse();
            rtsList.Reverse();
            count.Reverse();
            return new DataByTime(dateList, rtsList, count);
        }

        public DataByTime GetFavsOverMonth(IEnumerable<TwitterStatus> tweets)
        { 
            var favsList = new List<int>();
            var dateList = new List<string>();
            var twitterStatuses = tweets as IList<TwitterStatus> ?? tweets.ToList();
            int month = twitterStatuses[0].CreatedDate.Month;
            int value = 0;
            var count = new List<int>();
            int val = 0;
            foreach (var tweet in twitterStatuses)
            {
                if (tweet.CreatedDate.Month == month)
                {
                    val++;
                    value += tweet.FavoriteCount;
                }
                else
                {
                    count.Add(val);
                    val = 0;
                    dateList.Add(CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(month));
                    favsList.Add(value);
                    value = tweet.FavoriteCount;
                    month = tweet.CreatedDate.Month;
                }
            }
            dateList.Reverse();
            favsList.Reverse();
            count.Reverse();
            return new DataByTime(dateList, favsList, count);
        }

        public DataByTime GetRtsOverMonth(IEnumerable<TwitterStatus> tweets)
        {
            var rtsList = new List<int>();
            var dateList = new List<string>();
            var twitterStatuses = tweets as IList<TwitterStatus> ?? tweets.ToList();
            int month = twitterStatuses[0].CreatedDate.Month;
            int value = 0;
            var count = new List<int>();
            int val = 0;
            foreach (var tweet in twitterStatuses)
            {
                if (tweet.CreatedDate.Month == month)
                {
                    val++;
                    value += tweet.RetweetCount;
                }
                else
                {
                    count.Add(val);
                    val = 0;
                    dateList.Add(CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(month));
                    rtsList.Add(value);
                    value = tweet.RetweetCount;
                    month = tweet.CreatedDate.Month;
                }
            }
            dateList.Reverse();
            rtsList.Reverse();
            count.Reverse();
            return new DataByTime(dateList, rtsList, count);
        }

        public int GetAverageFavs(IEnumerable<TwitterStatus> tweets)
        {
            List<int> favList = tweets.Select(tweet => tweet.FavoriteCount).ToList();
            int average = favList.Sum();
            average /= favList.Count;
            return average;
        }

        public int GetAverageRt(IEnumerable<TwitterStatus> tweets)
        {
            List<int> RTList = tweets.Select(tweet => tweet.RetweetCount).ToList();
            int average = RTList.Sum();
            average /= RTList.Count;
            return average;
        }

        public TwitterUser GetProfileFor(string account)
        {
            return _service.GetUserProfileFor(new GetUserProfileForOptions { ScreenName = account });
        }

        public string GetUserProfileImage(TwitterUser user)
        {
            var url = user.ProfileImageUrl;
            url = Regex.Replace(url, "_normal", string.Empty);
            return url;
        }

        public string GetBannerUrl(TwitterUser user)
        {
            return user.ProfileBannerUrl;
        }

        public string GetUserName(TwitterUser user)
        {
            return user.Name;
        }

        public string GetFollowerCount(TwitterUser user)
        {
            return $"{user.FollowersCount:N0}";
        }

        public string GetFollowingCount(TwitterUser user)
        {
            return $"{user.FriendsCount:N0}";
        }

        public string GetTweetsCount(TwitterUser user)
        {
            return $"{user.StatusesCount:N0}";
        }

        public string GetCreateDate(TwitterUser user)
        {
            return user.CreatedDate.ToShortDateString();
        }

        public Tweet GetLatestTweet(TwitterUser user)
        {
            Tweet tweet = new Tweet(TweetToHtml(user.Status.Text) + " (" + user.Status.CreatedDate.ToShortDateString() + ")", user.Status.FavoriteCount, user.Status.RetweetCount);
            return tweet;
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
            List<string> newList = new List<string>();
            
            foreach (var hour in hours)
            {
                string val = "";
                switch (hour)
                {
                    case 0:
                        val = "12AM";
                        newList.Add(val);
                        break;
                    case 12:
                        val = "12PM";
                        newList.Add(val);
                        break;
                    default:
                        if (hour > 12)
                        {
                            var temp = hour;
                            temp -= 12;
                            val = temp + "PM";
                            newList.Add(val);
                        }
                        else newList.Add(hour + "AM");
                        break;
                }
            }

            return newList.Aggregate("", (current, item) => current + (item + " "));
        }

        /*------------------------------------------------------------------------------------------------------------------------
         * 
         *  Order results
         * 
         -----------------------------------------------------------------------------------------------------------------------*/

        readonly HashSet<string> _stopWords = new HashSet<string>
        {
            "a" , "about" , "above" , "after" , "again" , "against" , "all" , "am", "amp" , "an", "and", "any", "are", "aren't", "as", "at", "be", "because", "been", "before", "being", "below", "between", "both", "but", "by", "can", "can't", "cannot", "co", "could", "couldn't", "did", "didn't", "do", "does", "doesn't", "doing", "don't", "down", "dr", "during", "each" , "few",
            "for", "from", "further", "get", "gt","had", "hadn't", "has", "hasn't", "have", "haven't", "having", "he", "he'd", "he'll", "he's", "her", "here", "here's", "hers", "herself", "him", "himself", "his", "how", "how's", "http", "https", "i", "i'd", "i'll", "i'm", "i've", "if", "in", "into", "is", "isn't", "it", "it's", "its", "itself", "just", "let's", "ll", "me", "more", "most", "mustn't",
            "my", "myself", "no", "nor", "not", "of", "off", "on", "once", "only", "or", "other", "ought", "our", "ours" , "ourselves", "out", "over", "own", "pts", "re", "rd","rt", "same", "shan't", "she", "she'd", "she'll", "she's", "should", "shouldn't", "so", "some","st" ,"such", "th", "than", "that", "that's", "the", "their", "theirs", "them", "themselves", "then", "there", "there's", "these",
            "they", "they'd", "they'll", "they're", "they've","this", "those", "through", "to", "too", "under", "until", "up", "us","ve", "very", "was", "wasn't", "we", "we'd", "we'll", "we're", "we've", "were", "weren't", "what", "what's", "when", "when's", "where", "where's", "which", "while", "who", "who's", "whom", "why", "why's", "will", "with", "won't", "would",
            "wouldn't", "you", "you'd", "you'll", "you're", "you've", "your", "yours", "yourself", "yourselves"
        };

        // orders the words by count (no count cutouff)
        public Dictionary<string, int> Order(string tweets)
        {
            Dictionary<string, int> dictionary = new Dictionary<string, int>();
            string[] words = tweets.Replace(",", "").Replace("  ", " ").Split(' ');
            foreach (string word in words)
            {
                if (word == "") continue; //ignore the null that kept appearing
                if (word.Length < 2) continue;
                if (_stopWords.Contains(word)) continue;

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
                if (word.Length < 2) continue;
                if (_stopWords.Contains(word)) continue;

                if (!dictionary.ContainsKey(word)) dictionary.Add(word, 1);
                else dictionary[word]++;
            }
            var keysToRemove = dictionary.Where(kvp => kvp.Value <= cutoff) // <--- value here is cutoff for word freq.
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
            return list.Aggregate("", (current, value) => current + (value + "<br />"));
        }

        /*------------------------------------------------------------------------------------------------------------------------
         * 
         *  Misc Functionsresults
         * 
         -----------------------------------------------------------------------------------------------------------------------*/

        private static string TweetToHtml(string msg)
        {
            const string regex = @"((www\.|(http|https|ftp|news|file)+\:\/\/)[&#95;.a-z0-9-]+\.[a-z0-9\/&#95;:@=.+?,##%&~-]*[^.|\'|\# |!|\(|?|,| |>|<|;|\)])";
            Regex r = new Regex(regex, RegexOptions.IgnoreCase);
            return r.Replace(msg, "<a href=\"$1\" title=\"Click to open in a new window or tab\" target=\"&#95;blank\">$1</a>").Replace("href=\"www", "href=\"http://www");
        }

        // returns a tweet without any of the twitter jargin
        private static string ParseText(string tweets)
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