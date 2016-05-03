<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="MySql.Data.MySqlClient" %>

<%@ Page Language="C#" Debug="true" %>

<html>
<head>
    <title>Manage Users</title>
    <link href="https://fonts.googleapis.com/css?family=Varela+Round" rel="stylesheet" type="text/css" />
    <link href="../../css/Manage-Style.css" rel="stylesheet" type="text/css" />
</head>
<body>

    <div id="container">
        <form runat="server">
            <div id="top">
                <h1 id="sl-title">Users</h1>
            </div>
            <asp:GridView ID="myGridview" runat="server" AutoGenerateColumns="false"
                DataKeyNames="id" CellPadding="10" CellSpacing="0"
                ShowFooter="true"
                CssClass="myGrid" HeaderStyle-CssClass="header" RowStyle-CssClass="trow1"
                AlternatingRowStyle-CssClass="trow2"
                OnRowCommand="myGridview_RowCommand"
                OnRowCancelingEdit="myGridview_RowCancelingEdit"
                OnRowDeleting="myGridview_RowDeleting"
                OnRowEditing="myGridview_RowEditing"
                OnRowUpdating="myGridview_RowUpdating">

                <AlternatingRowStyle CssClass="trow2"></AlternatingRowStyle>
                <FooterStyle CssClass="foot"></FooterStyle>

                <Columns>
                    <asp:TemplateField>
                        <HeaderTemplate>Username</HeaderTemplate>
                        <ItemTemplate><%#Eval("username") %></ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="usernameTxt" runat="server" Text='<%#Bind("username") %>' />
                            <asp:RequiredFieldValidator ID="rfCPEdit1" runat="server" ErrorMessage="*" CssClass="reqField"
                                Display="Dynamic" ValidationGroup="edit" ControlToValidate="usernameTxt">Required</asp:RequiredFieldValidator>
                        </EditItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox placeholder="Username" ID="usernameTxt" runat="server"></asp:TextBox><br />
                            <asp:RequiredFieldValidator CssClass="reqField" ID="rfCN" runat="server" ErrorMessage="*"
                                Display="Dynamic" ValidationGroup="Add" ControlToValidate="usernameTxt">Required</asp:RequiredFieldValidator>
                        </FooterTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField>
                        <HeaderTemplate>Password</HeaderTemplate>
                        <ItemTemplate><%#Eval("pwd") %></ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="passwordTxt" runat="server" Text='<%#Bind("pwd") %>' />
                            <asp:RequiredFieldValidator CssClass="reqField" ID="rfCPEdit2" runat="server" ErrorMessage="*"
                                Display="Dynamic" ValidationGroup="edit" ControlToValidate="passwordTxt">Required</asp:RequiredFieldValidator>
                        </EditItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox placeholder="Password" ID="passwordTxt" runat="server"></asp:TextBox><br />
                            <asp:RequiredFieldValidator CssClass="reqField" ID="rfCN2" runat="server" ErrorMessage="*"
                                Display="Dynamic" ValidationGroup="Add" ControlToValidate="passwordTxt">Required</asp:RequiredFieldValidator>
                        </FooterTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField>
                        <HeaderTemplate>Twitter</HeaderTemplate>
                        <ItemTemplate><%#Eval("twitter") %></ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="twitterTxt" runat="server" Text='<%#Bind("twitter") %>' />
                            <asp:RequiredFieldValidator CssClass="reqField" ID="rfCPEdit3" runat="server" ErrorMessage="*"
                                Display="Dynamic" ValidationGroup="edit" ControlToValidate="twitterTxt">Required</asp:RequiredFieldValidator>
                        </EditItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox placeholder="Twitter" ID="twitterTxt" runat="server"></asp:TextBox><br />
                            <asp:RequiredFieldValidator CssClass="reqField" ID="rfCN3" runat="server" ErrorMessage="*"
                                Display="Dynamic" ValidationGroup="Add" ControlToValidate="twitterTxt">Required</asp:RequiredFieldValidator>
                        </FooterTemplate>
                    </asp:TemplateField>


                    <asp:TemplateField>
                        <HeaderTemplate>Role</HeaderTemplate>
                        <ItemTemplate><%#Eval("role") %></ItemTemplate>
                        <EditItemTemplate>
                            <asp:DropDownList ID="roleTxt" runat="server" AutoPostBack="true">
                                <asp:ListItem Value="" Text="Select Role"></asp:ListItem>
                                <asp:ListItem Value="admin" Text="admin"></asp:ListItem>
                                <asp:ListItem Value="member" Text="member"></asp:ListItem>
                                <asp:ListItem Value="public" Text="public">public</asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfCPEdit4" runat="server" ErrorMessage="*" CssClass="reqField"
                                Display="Dynamic" ValidationGroup="edit" ControlToValidate="roleTxt">Required</asp:RequiredFieldValidator>
                        </EditItemTemplate>
                        <FooterTemplate>
                            <asp:DropDownList ID="roleTxt" runat="server">
                                <asp:ListItem Value="" Text="Select Role"></asp:ListItem>
                                <asp:ListItem Value="admin" Text="Admin"></asp:ListItem>
                                <asp:ListItem Value="member" Text="Member"></asp:ListItem>
                                <asp:ListItem Value="public" Text="Public"></asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator CssClass="reqField" ID="rfCN4" runat="server" ErrorMessage="*"
                                Display="Dynamic" ValidationGroup="Add" ControlToValidate="roleTxt">Required</asp:RequiredFieldValidator>
                        </FooterTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField>
                        <ItemTemplate>
                            <asp:ImageButton CssClass="linkBtn" ImageUrl="../../images/delete.png" ID="delBtn" runat="server" CommandName="Delete"></asp:ImageButton>
                            <asp:ImageButton CssClass="linkBtn" ImageUrl="../../images/edit.png" ID="editBtn" runat="server" OnClientClick="removePadding()" CommandName="Edit"></asp:ImageButton>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:ImageButton CssClass="linkBtn" ImageUrl="../../images/check.png" ID="updateBtn" runat="server" CommandName="Update" ValidationGroup="edit"></asp:ImageButton>
                            <asp:ImageButton CssClass="linkBtn" ImageUrl="../../images/close.png" ID="cancelBtn" runat="server" CommandName="Cancel"></asp:ImageButton>
                        </EditItemTemplate>
                        <FooterTemplate>
                            <asp:Button ID="addBtn" runat="server" Text="Add" CommandName="Insert" oncliValidationGroup="Add" />
                        </FooterTemplate>
                    </asp:TemplateField>

                </Columns>

                <HeaderStyle CssClass="header"></HeaderStyle>
                <RowStyle CssClass="trow1"></RowStyle>

            </asp:GridView>
        </form>
        <div id="nav">
            <ul id="nav-content">
                <li><a href="../Viewer.aspx">Home</a></li>
                <li><a href="../../Doc.aspx">Documentation</a></li>
                <li id="manage" runat="server" class="nav-select"><a href="#">Manage Users</a></li>
            </ul>
        </div>
    </div>
</body>
</html>

<script language="C#" runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindGrid();
        }
    }

    private void BindGrid()
    {
        string connectString = ConfigurationManager.AppSettings["connectString"];
        using (MySqlConnection connection = new MySqlConnection(connectString))
        {
            using (MySqlCommand query = new MySqlCommand("SELECT * FROM accounts"))
            {
                using (MySqlDataAdapter adapter = new MySqlDataAdapter())
                {
                    query.Connection = connection;
                    adapter.SelectCommand = query;
                    using (DataTable dt = new DataTable())
                    {
                        adapter.Fill(dt);
                        myGridview.DataSource = dt;
                        myGridview.DataBind();
                    }
                }
            }
        }
    }

    protected void myGridview_RowCommand(object sender, CommandEventArgs e)
    {
        //Insert new contact
        if (e.CommandName != "Insert") return;
        Page.Validate("Add");
        if (!Page.IsValid) return;

        var fRow = myGridview.FooterRow;
        string username = (fRow.FindControl("usernameTxt") as TextBox).Text;
        string password = (fRow.FindControl("passwordTxt") as TextBox).Text;
        string twitter = (fRow.FindControl("twitterTxt") as TextBox).Text;
        string role = (fRow.FindControl("roleTxt") as DropDownList).SelectedItem.Value;

        MySqlCommand query = new MySqlCommand("INSERT INTO accounts (username, pwd, twitter, role) VALUES (@username, @password, @twitter, @role)");

        string connectionString = ConfigurationManager.AppSettings["connectString"];
        using (MySqlConnection connection = new MySqlConnection(connectionString))
        {
            using (query)
            {
                using (MySqlDataAdapter adapter = new MySqlDataAdapter())
                {
                    query.Parameters.Add("@username", username);
                    query.Parameters.Add("@password", password);
                    query.Parameters.Add("@twitter", twitter);
                    query.Parameters.Add("@role", role);
                    query.Connection = connection;
                    connection.Open();
                    query.ExecuteNonQuery();
                    connection.Close();
                }
            }
        }
        BindGrid();
    }

    protected void myGridview_RowEditing(object sender, GridViewEditEventArgs e)
    {
        myGridview.EditIndex = e.NewEditIndex;
        BindGrid();

    }

    protected void myGridview_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
    {
        //Cancel Edit Mode 
        myGridview.EditIndex = -1;
        BindGrid();
    }

    protected void myGridview_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        GridViewRow row = myGridview.Rows[e.RowIndex];
        int id = Convert.ToInt32(myGridview.DataKeys[e.RowIndex].Values[0]);

        string username = (row.FindControl("usernameTxt") as TextBox).Text;
        string password = (row.FindControl("passwordTxt") as TextBox).Text;
        string twitter = (row.FindControl("twitterTxt") as TextBox).Text;
        string role = (row.FindControl("roleTxt") as DropDownList).SelectedItem.Value;
        

        MySqlCommand query = new MySqlCommand("UPDATE accounts SET username= @username, pwd= @password, twitter=@twitter, role= @role WHERE id = @id");

        string connectionString = ConfigurationManager.AppSettings["connectString"];
        using (MySqlConnection connection = new MySqlConnection(connectionString))
        {
            using (query)
            {
                using (MySqlDataAdapter adapter = new MySqlDataAdapter())
                {
                    query.Parameters.Add("@id", id);
                    query.Parameters.Add("@username", username);
                    query.Parameters.Add("@password", password);
                    query.Parameters.Add("@twitter", twitter);
                    query.Parameters.Add("@role", role);

                    query.Connection = connection;
                    connection.Open();
                    query.ExecuteNonQuery();
                    connection.Close();
                }
            }
        }
        myGridview.EditIndex = -1;
        BindGrid();
    }


    protected void myGridview_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        int id = Convert.ToInt32(myGridview.DataKeys[e.RowIndex].Values[0]);

        string connectionString = ConfigurationManager.AppSettings["connectString"];
        using (MySqlConnection connection = new MySqlConnection(connectionString))
        {
            using (MySqlCommand query = new MySqlCommand("DELETE FROM accounts WHERE id = @id"))
            {
                using (MySqlDataAdapter adapter = new MySqlDataAdapter())
                {
                    query.Parameters.Add("@id", id);
                    query.Connection = connection;
                    connection.Open();
                    query.ExecuteNonQuery();
                    connection.Close();
                }
            }
        }
        BindGrid();
    }

</script>
