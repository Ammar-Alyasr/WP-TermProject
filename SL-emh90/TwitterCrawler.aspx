<%@ Page Language="C#" Debug="true" %>

<%@ Import Namespace="TweetSharp" %>
<%@ Import Namespace="System.Collections.Generic" %>


<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link rel="stylesheet" type="text/css" href="http://visapi-gadgets.googlecode.com/svn/trunk/wordcloud/wc.css" />
    <script type="text/javascript" src="http://visapi-gadgets.googlecode.com/svn/trunk/wordcloud/wc.js"></script>
    <script type="text/javascript" src="http://www.google.com/jsapi"></script>
    <title>WP-Term Project</title>
</head>
<body>
    <form id="form1" runat="server">
        <div runat="server">
            <h3>Twitter Crawler</h3>
            <p>Enter a term to return all occurences in recent tweets</p>
            <p>Search with a '#' at the beginning to search by hashtag</p>
            <p>Search with a '@' at the beginning to search a specified user's timeline</p>
            <asp:TextBox ID="tb_input" runat="server"></asp:TextBox>
            <asp:Button ID="btn_search" runat="server" Text=" Get " OnClick="btn_search_Click" />
            <asp:Button ID="btn_view" runat="server" OnClick="btn_view_Click" Text="View Tweets" Style="height: 26px" />
            <div id="tweetList" runat="server"></div>
        </div>
        <div id="wcdiv" style="width: 400px;"></div>
    </form>
    <script type="text/javascript">
        var text = '<%= TweetsText %>';
        google.load("visualization", "1");
        google.setOnLoadCallback(draw);
        function draw() {
            var data = new google.visualization.DataTable();
            data.addColumn('string', 'Text1');
            data.addRows(1);
            data.setCell(0, 0, text);
            var outputDiv = document.getElementById('wcdiv');
            var wc = new WordCloud(outputDiv);
            wc.draw(data, null);
        }
    </script>
</body>
</html>

<script language="C#" runat="server">

    public string Query = "";
    public string TweetsText = "";
    public string Token = "589683699-2Lch4rjFMFv7CCLznoTUrlj5eMAWihEhYazRHl5P";
    public string TokenSecret = "YIZNZ0PbqUaRZfzKjrqcsj2SnIcF4vnhEI2WPf4vKbOMu";
    public string ConsumerKey = "JlhAPdbEXK7EShHW2nbLSMb9o";
    public string ConsumerSecret = "mHW5x5a3HZ2n0S1PMXVBomk4wJZsHrEvjqmc8eag29qP9vFQll";

    protected void btn_search_Click(object sender, EventArgs e)
    {
        tweetList.InnerHtml = string.Empty;
        Query = tb_input.Text;
        switch (Query[0])
        {
            case '#':
                TweetsText = getTextHash();
                Process(Query);

                // Key value pair print
                // thinking of using a term cloud instead of the word cloud. also can do charts with this.
                var dictionary = Process(TweetsText);
                string html = "";
                foreach (var kvp in dictionary)
                {
                    html += string.Format("Key= {0}, Value= {1} <br/>", kvp.Key, kvp.Value);
                }
                tweetList.InnerHtml = html;

                break;
            case '@':
                TweetsText = getTextTimeLine();

                dictionary = Process(TweetsText);
                html = "";
                foreach (var kvp in dictionary)
                {
                    html += string.Format("Key= {0}, Value= {1} <br/>", kvp.Key, kvp.Value);
                }
                tweetList.InnerHtml = html;

                break;
            default:
                TweetsText = getTextHash();
                Process(Query);

                dictionary = Process(TweetsText);
                html = "";
                foreach (var kvp in dictionary)
                {
                    html += string.Format("Key= {0}, Value= {1} <br/>", kvp.Key, kvp.Value);
                }
                tweetList.InnerHtml = html;
                break;
        }
    }

    protected void btn_view_Click(object sender, EventArgs e)
    {
        Query = tb_input.Text;
        switch (Query[0])
        {
            case '#':
                HashtagSearch(Query);
                break;
            case '@':
                TimelineSearch(Query);
                break;
            default:
                HashtagSearch(Query);
                break;
        }
    }

    protected void HashtagSearch(string term)
    {
        var service = new TwitterService(ConsumerKey, ConsumerSecret);
        service.AuthenticateWith(Token, TokenSecret);
        var sOptions = new SearchOptions
        {
            Q = Query,
            Count = 100,
            Lang = "en"
        };
        var tweets = service.Search(sOptions);
        int i = 1;
        string html = "";
        foreach (var tweet in tweets.Statuses)
        {
            html += string.Format("{0,-5}: {1} {2} - {3} <br/>", i, tweet.CreatedDate, tweet.User.ScreenName, tweet.Text);
            i++;
        }
        tweetList.InnerHtml = html;
    }

    protected void TimelineSearch(string user)
    {
        var service = new TwitterService(ConsumerKey, ConsumerSecret);
        service.AuthenticateWith(Token, TokenSecret);
        var uOptions = new ListTweetsOnUserTimelineOptions()
        {
            ScreenName = Query,
            Count = 200
        };

        var tweets = service.ListTweetsOnUserTimeline(uOptions);
        int i = 1;
        string html = "";
        foreach (var tweet in tweets)
        {
            html += string.Format("{0, -5}: {1}: {2} - {3} <br/>", i, tweet.CreatedDate, tweet.User.ScreenName, tweet.Text);
            i++;
        }
        tweetList.InnerHtml = html;
    }

    private string getTextTimeLine()
    {
        var service = new TwitterService(ConsumerKey, ConsumerSecret);
        service.AuthenticateWith(Token, TokenSecret);
        var uOptions = new ListTweetsOnUserTimelineOptions()
        {
            ScreenName = Query,
            Count = 200
        };
        var tweets = service.ListTweetsOnUserTimeline(uOptions);

        string text = "";
        foreach (var tweet in tweets)
        {
            text += ParseTweet(tweet.Text);
        }
        return text;
    }

    private string getTextHash()
    {
        var service = new TwitterService(ConsumerKey, ConsumerSecret);
        service.AuthenticateWith(Token, TokenSecret);
        var sOptions = new SearchOptions
        {
            Q = Query,
            Count = 100,
            Lang = "en"
        };
        var tweets = service.Search(sOptions);

        string text = "";
        foreach (var tweet in tweets.Statuses)
        {
            text += ParseTweet(tweet.Text);
        }
        return text;
    }

    private string ParseTweet(string rawTweet)
    {
        Regex link = new Regex(@"http(s)?://([\w+?\.\w+])+([a-zA-Z0-9\~\!\@\#\$\%\^\&amp;\*\(\)_\-\=\+\\\/\?\.\:\;\'\,]*)?");
        Regex screenName = new Regex(@"@\w+");
        Regex hashTag = new Regex(@"#\w+");

        string formattedTweet = link.Replace(rawTweet, string.Empty);
        formattedTweet = screenName.Replace(formattedTweet, string.Empty);
        formattedTweet = hashTag.Replace(formattedTweet, string.Empty);
        formattedTweet = Regex.Replace(formattedTweet, "[^0-9A-Za-z ,]", " "); ; //removes special chars
        formattedTweet = Regex.Replace(formattedTweet, @"[\d-]", string.Empty); //remove numbers


        return formattedTweet;
    }

    public static Dictionary<string, int> Process(string phrase)
    {
        Dictionary<string, int> wordsAndCount = new Dictionary<string, int>();

        string[] words = phrase.Replace("\"", "").Replace("'", "").Replace(".", "").Replace(",", "").Replace("\n", "").Split(' ');
        for (int index = 0; index < words.Length; index++)
        {
            string word = words[index];
            if (!wordsAndCount.ContainsKey(word))
                wordsAndCount.Add(word, 1);
            else
                wordsAndCount[word]++;
        }

        var temp = wordsAndCount.OrderByDescending(ac => ac.Value);
        return temp.ToDictionary(t => t.Key, t => t.Value);
    }
</script>
