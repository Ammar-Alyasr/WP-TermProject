<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="MySql.Data.MySqlClient" %>

<%@ Page Language="C#" Debug="true" %>

<html>
<body>
    <form id="form1" runat="server">
    <div>
    
        <asp:Label ID="Label1" runat="server" Font-Size="XX-Large" Text="Sign Up"></asp:Label>
        <br />
        <br />
        <br />
        <asp:Label ID="Label2" runat="server" Text="Username:"></asp:Label>
        <asp:TextBox ID="UsernameTxtB" runat="server"></asp:TextBox>
        <br />
        <br />
        <asp:Label ID="Label3" runat="server" Text="Password:"></asp:Label>
        <asp:TextBox ID="PasswordTxtB" runat="server"></asp:TextBox>
        <br />
        <br />
        <asp:Label ID="Label4" runat="server" Text="Twitter Account:"></asp:Label>
        <asp:TextBox ID="TAccountTxtB" runat="server"></asp:TextBox>
        <br />
        <br />
        <asp:Button ID="CreateAccountBtn" OnClick="OnSignUp" runat="server" Text="Create Account" />
    
    </div>
    </form>
</body>
</html>

<script language="C#" runat="server">


  public void OnSignUp(Object sender, EventArgs e)
  {
    string ConnectString = "server=us-cdbr-iron-east-03.cleardb.net;database= heroku_6610293399c822c;uid= baaa895c37202a;pwd=906311ad;allow zero datetime=yes";
	String SMemebr = "member";
	string myString = "INSERT INTO heroku_6610293399c822c.accounts(id,username, pwd, twitter, role)" 
	+  "Values('"+"0"+"', '"+UsernameTxtB.Text+ "', '" +PasswordTxtB.Text +"', '" +TAccountTxtB.Text+"', '" +"member"+"')";
	
    MySqlDataAdapter adapter = new MySqlDataAdapter(myString, ConnectString);
	DataSet ds = new DataSet ();
    adapter.Fill (ds);
	
	Response.Redirect ("TermProject/Viewer.aspx");
  }
</script>
