<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="MySql.Data.MySqlClient" %>
<%@ Import Namespace="System.Security.Principal" %>

<script language="C#" runat="server">
  void Application_AuthenticateRequest (Object sender, EventArgs e)
  {
      HttpApplication app = (HttpApplication) sender;

      if (app.Request.IsAuthenticated &&
          app.User.Identity is FormsIdentity) {
          FormsIdentity identity = (FormsIdentity) app.User.Identity;

          // Find out what role (if any) the user belongs to
          string role = GetUserRole (identity.Name);

          // Create a GenericPrincipal containing the role name
          // and assign it to the current request
          if (role != null)
              app.Context.User = new GenericPrincipal (identity,
                  new string[] { role });
      }
  }

  string GetUserRole (string name)
  {
      MySqlConnection connection = new MySqlConnection
          ("server=us-cdbr-iron-east-03.cleardb.net;database=heroku_6610293399c822c;uid=baaa895c37202a;pwd=906311ad"); 

      try {
          connection.Open ();

          StringBuilder builder = new StringBuilder ();
          builder.Append ("select role from accounts " +
              "where username = \'");
          builder.Append (name);
          builder.Append ("\'");

          MySqlCommand command = new MySqlCommand (builder.ToString (),
              connection);

          object role = command.ExecuteScalar ();

          if (role is DBNull)
              return null;

          return (string) role;
      }
      catch (MySqlException) {
          return null;
      }
      finally {
          connection.Close ();
      }
  }
</script>