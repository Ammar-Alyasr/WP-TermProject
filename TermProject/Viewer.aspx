<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Viewer.aspx.cs" Inherits="TermProject.Viewer" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link rel="stylesheet" type="text/css" href="http://visapi-gadgets.googlecode.com/svn/trunk/wordcloud/wc.css" />
    <script type="text/javascript" src="http://visapi-gadgets.googlecode.com/svn/trunk/wordcloud/wc.js"></script>
    <script type="text/javascript" src="http://www.google.com/jsapi"></script>
    <title>WP-Term Project</title>
</head>
<body>
    <form runat="server">
        <div runat="server">
            <h3>Twitter Crawler</h3>
            <p>Enter a term to return all occurences in recent tweets</p>
            <p>Search with a '#' at the beginning to search by hashtag</p>
            <p>Search with a '@' at the beginning to search a specified user's timeline</p>
            <p>Note: Because of how the twitter API works its best to do count values divisible by 200</p>
            <asp:TextBox ID="tb_input" runat="server" placeholder="Query"></asp:TextBox>
            <asp:TextBox ID="tb_count" runat="server" placeholder="Count"></asp:TextBox>
            <asp:Button ID="btn_serach" runat="server" Text="Search" Height="26px" OnClick="btn_serach_Click" />
            <div id="mydiv" runat="server"></div>
        </div>
        <!-- wordcloud view-
        <div id="wcdiv" style="width: 400px;"></div>  -->
    </form>

    <!-- javascript for wordcloud
    <script type="text/javascript">
        var text = ;
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
    </script
        -->

</body>
</html>

