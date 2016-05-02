<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="MySql.Data.MySqlClient" %>

<%@ Page Language="C#" Debug="true" %>

<html>
<head>
    <Title>Sign Up</Title>
    <link href="css/SignUp-Style.css" type="text/css" rel="stylesheet"/>
</head>
<body>
    <div id="container">
        <div id="top">
            <h1>Create an account</h1>
        </div>
        <form runat="server">
            <div id="signin">
                <asp:TextBox ID="UsernameTxtB" runat="server" placeholder="Username" />
                <asp:TextBox ID="PasswordTxtB" TextMode="password" runat="server" placeholder="Password" />
                <asp:TextBox ID="TAccountTxtB" runat="server" placeholder="Twitter Account" />
                <asp:Button ID="CreateAccountBtn" Text="Sign Up" OnClick="OnSignUp" runat="server" />
            </div>
            <div id="existing">
                <p>Existing User? <asp:LinkButton ID="btn_login" Text="Login" OnClick="LoginPage" runat="server" /></p>
				
            </div>
        </form>
    </div>
</body>
</html>

<script language="C#" runat="server">

    	
	public void LoginPage(object sender, EventArgs e)
	{
		Response.Redirect ("Login.aspx");
	}

    public void OnSignUp(object sender, EventArgs e)
    {
        string ConnectString = "server=us-cdbr-iron-east-03.cleardb.net;database= heroku_6610293399c822c;uid= baaa895c37202a;pwd=906311ad;allow zero datetime=yes";
        string myString = "INSERT INTO heroku_6610293399c822c.accounts(id,username, pwd, twitter, role)"
        + "Values('" + "0" + "', '" + UsernameTxtB.Text + "', '" + PasswordTxtB.Text + "', '" + TAccountTxtB.Text + "', '" + "member" + "')";

        MySqlDataAdapter adapter = new MySqlDataAdapter(myString, ConnectString);
        DataSet ds = new DataSet();
        adapter.Fill(ds);

        FormsAuthentication.RedirectFromLoginPage(UsernameTxtB.Text, false);
    }
</script>
