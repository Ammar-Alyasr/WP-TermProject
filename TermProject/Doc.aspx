<%@ Page Language="C#" Debug="true" %>

<html>
<head>
    <title>Manage Users</title>
    <link href="https://fonts.googleapis.com/css?family=Varela+Round" rel="stylesheet" type="text/css" />
    <link href="css/Doc-Style.css" rel="stylesheet" type="text/css" />
</head>
<body>

    <div id="container">
        <div id="content">
            <div id="help">
                <h1 class="content-title">Help Information</h1>
                <h4>Welcome to an ASP.NET based Twitter Analytics Web Application!</h4>
                <div id="spacer"></div>
                <br />
                <p>
                    This is an application which will analyze your given twitter account and compile various results for you to see.
                    To use the application, just create an account and login. Once login the page will load with the data that you can view.
                </p>
                <p>
                    You will see that the page will be customized based on your twitter account. To logout, there is a "logout" button at the
                    top of the page. Click it and you will be redirected to the login page again.
                </p>
                <p>
                    There are many feature yet to add. The only current function is to do an analysis based of the twitter account provided.
                    Later versions will include a search function and the ability to edit your accout.
                </p>
            </div>
            <br />

            <div id="tech">
                <h1 class="content-title">Technical Document</h1>
                <div id="spacer2"></div>
                <br/>
                <h4>Architecture</h4>
                <p>
                    This is a web application built on C#'s ASP.NET. Therefore, it's an IIS based server application with a code-behind model.
                    The server is interactive with a mySQL based datastore running from a free version of ClearDB. 
                    The database is holding only user account information. The client is a web browser with the standard HTM5L/CSS technologies.
                    Sprinkled in is some Javascript form client-side manipulations, along with the pulling data to view from the server. 
                </p>
                <h4>Business Logic</h4>
                <p>
                    The logic within the code is based around the idea of twitter analytics. The logic is required to grab, parse and display various
                    data to the client. The grabbing is done by a C# library called TweetSharp which abstracts away some of the messier methods involved with the Twitter API.
                    The parseing is done in a few ways. First the Twitter REST API returns as JSON so the JSON.NET library is used the parse the response.
                    Then various C# functions parse that to collect various data within the response (like hashtags count, mentions count, etc.).
                    The data is serialized back to JSON to send to the Javascript charting libraries. We are using D3 and Chart.js charting libraries for displaying data.
                </p>
                <h4>Security Model</h4>
                <p>
                    The security model is a form and role based security system. This is very similar the same as project 5, where users are given a role and can only
                    see certain information based off that role. The roles we have are: admin, member and public. On sign up the only role given is member. Admin can only
                    be grated from another admin in the Manage page. This is a page that is not accessable to anyone other than admins. Members are allowed to the viewer page
                    and this documentation page. Public cannot access anything but the login and sign up pages.
                </p>
                <h4>Database Design</h4>
                <p>
                    The database is mySQL based. It has only one table with five columns. First is the auto increment integer ID columnn to provide an ID to the user.
                    Then there are the user entered username, password and twitter varchar columns which define what they are named. Lastly is the varchar role column to define 
                    the user's access level.
                </p>
                <h4>Developers</h4>
                <p>
                    Eric Harvey: Twitter crawler logic and page design. 50% <br />
                    Keith Kretz: Login/Sign-up and security. 50%
                </p>
            </div>
        </div>
        <div id="nav">
            <ul id="nav-content">
                <li><a href="Viewer/Viewer.aspx">Home</a></li>
                <li class="nav-select"><a href="#">Documentation</a></li>
                <li id="manage" runat="server"><a href="Viewer/Manage/Manage.aspx">Manage Users</a></li>
            </ul>
        </div>
    </div>
</body>
</html>
