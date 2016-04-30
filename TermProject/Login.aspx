<%@ Import Namespace="MySql.Data.MySqlClient" %>

<%@ Page Language="C#" Debug="true" %>

<html>
<head>
    <title>Login</title>
    <link href="css/Login-Style.css" rel="stylesheet" type="text/css" />
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:400,600" rel="stylesheet" type="text/css">
</head>
<body>
    <div id="container">
        <div id="top">
            <h1>Login to your account</h1>
        </div>
        <form runat="server">
            <div id="login">
                <h3><asp:Label ID="Output" runat="server" /></h3>
                <asp:TextBox ID="UserName" runat="server" placeholder="Username" />
                <asp:TextBox ID="Password" TextMode="password" runat="server" placeholder="Password" />
                <asp:CheckBox CssClass="checkbox" ID="cb_remember" Text="Remember Me" runat="server" />
                <asp:Button ID="btn_login" Text="Login" OnClick="OnLogIn" runat="server" />
            </div>
            <div id="signin">
                <p>New User?</p>
				<asp:Button ID="btn_SignUp" Text="Sign Up" OnClick="SignUpPage" runat="server" />
            </div>
        </form>
    </div>
</body>
</html>

<script language="C#" runat="server">


    protected void OnLogIn(object sender, EventArgs e)
    {
        if (CustomAuthenticate(UserName.Text, Password.Text))
        {
            string url = FormsAuthentication.GetRedirectUrl(UserName.Text, cb_remember.Checked);

            FormsAuthentication.SetAuthCookie(UserName.Text, cb_remember.Checked);

            if (!cb_remember.Checked)
            {
                HttpCookie cookie = Response.Cookies[FormsAuthentication.FormsCookieName];
                cookie.Expires = DateTime.Now + new TimeSpan(0, 0, 8, 0);
            }
            Response.Redirect(url);
        }
        else Output.Text = "Invalid login";
		
		
    }
	
	
	public void SignUpPage(object sender, EventArgs e)
	{
		Response.Redirect ("SignUp.aspx");
	}
	
    private static bool CustomAuthenticate(string username, string password)
    {
        MySqlConnection connection = new MySqlConnection("server = us-cdbr-iron-east-03.cleardb.net;" +
                                                         "database = heroku_6610293399c822c;" +
                                                         "uid = baaa895c37202a;" +
                                                         "pwd = 906311ad;");
        try
        {
            connection.Open();

            StringBuilder builder = new StringBuilder();
            builder.Append("SELECT COUNT(*) FROM accounts WHERE username = \'");
            builder.Append(username);
            builder.Append("\' and pwd = \'");
            builder.Append(password);
            builder.Append("\';");

            MySqlCommand command = new MySqlCommand(builder.ToString(), connection);

            long count = (long) command.ExecuteScalar ();
			return(count > 0);
        }
        catch (MySqlException)
        {
            return false;
        }
        finally
        {
            connection.Close();
        }
    }
</script>
