<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="TweetSharp" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div runat="server">
            <h3>Twitter Crawler</h3>
            <p>Enter a term to return all occurences in recent tweets</p>
            <p>Search with a '#' at the beginning to search by hashtag</p>
            <p>Search with a '@' at the beginning to search a specified user's timeline</p>
            <asp:TextBox ID="tb_input" runat="server"></asp:TextBox>
            <asp:Button ID="btn_search" runat="server" Text="Search" OnClick="btn_search_Click" />
            <div id="tweetList" runat="server"></div>
        </div>
    </form>
</body>
</html>

<script language="C#" runat="server">

    public string Query = "";

    public string Token = "589683699-2Lch4rjFMFv7CCLznoTUrlj5eMAWihEhYazRHl5P";
    public string TokenSecret = "YIZNZ0PbqUaRZfzKjrqcsj2SnIcF4vnhEI2WPf4vKbOMu";
    public string ConsumerKey = "JlhAPdbEXK7EShHW2nbLSMb9o";
    public string ConsumerSecret = "mHW5x5a3HZ2n0S1PMXVBomk4wJZsHrEvjqmc8eag29qP9vFQll";


    protected void Page_Load(object sender, EventArgs e)
    {
        //
    }

    protected void btn_search_Click(object sender, EventArgs e)
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
            html += string.Format("{0, -5}: {1} {2} - {3} <br/>", i, tweet.CreatedDate, tweet.User.ScreenName, tweet.Text);
            i++;
        }
        tweetList.InnerHtml = html;
    }

</script>
