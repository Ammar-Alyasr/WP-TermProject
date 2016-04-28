<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Viewer.aspx.cs" Inherits="TermProject.Viewer" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href='https://fonts.googleapis.com/css?family=Open+Sans:400,600' rel='stylesheet' type='text/css'>
    <link rel="stylesheet" type="text/css" href="Viewer-Style.css" />
    <title>WP-Term Project</title>
</head>
<body>

    <div id="container">

        <div id="content" runat="server">
            <div id="header-back"style="background-image:url(<%=BannerUrl%>)"></div>
            <div id="header">
                <img src="<%= ProfileUrl %>" />
                <h3>Hello, <%=Name%></h3>
            </div>
            <div id="data">
                <form runat="server">
                    <h3>Twitter Crawler</h3>
                    <p>Enter a term to return all occurences in recent tweets</p>
                    <p>Search with a '#' at the beginning to search by hashtag</p>
                    <p>Search with a '@' at the beginning to search a specified user's timeline</p>
                    <p>Note: Because of how the twitter API works its best to do count values divisible by 200</p>
                    <asp:TextBox ID="tb_input" runat="server" placeholder="Query"></asp:TextBox>
                    <asp:TextBox ID="tb_count" runat="server" placeholder="Count"></asp:TextBox>
                    <asp:Button ID="btn_serach" runat="server" Text="Search" Height="26px" OnClick="btn_serach_Click" />
                    <div id="mydiv" runat="server"></div>
                </form>
            </div>

        </div>

        <div id="nav">
            <ul id="nav-content">
                <li><a href="#">Login</a></li>
                <li><a href="#">Home</a></li>
                <li><a href="#">Search</a></li>
                <li><a href="#">Edit Account</a></li>
            </ul>
        </div>
    </div>


</body>
</html>

