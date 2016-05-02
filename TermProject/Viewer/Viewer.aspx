<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Viewer.aspx.cs" Inherits="TermProject.Viewer.Viewer" EnableEventValidation="false" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <link href="https://fonts.googleapis.com/css?family=Varela+Round" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" type="text/css" href="../css/Viewer-Style.css" />
    <script src="http://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
    <link href="../css/grid12.css" rel="stylesheet" />
    <script src="../scripts/Chart.js"></script>
    <title>WP-Term Project</title>
</head>
<body>
    <div id="container">
        <div id="content" runat="server">
            <div id="header-back" style="background-image: url(<%=BannerUrl%>)"></div>
            <div id="header">
                <img src="<%= ProfileUrl %>" />
                <h3>Hello, <%=Name%></h3>
                <a runat="server" onserverclick="LogOut" id="logout">Log Out</a>
            </div>
            <div id="data">
                <form runat="server">
                    <div id="basic-stats" class="row">
                        <div class="col-lg-3">
                            <p class="basic">Tweets</p>
                            <p class="bStat"><%= TweetCount %></p>
                        </div>
                        <div class="col-lg-3">
                            <p class="basic">Followers</p>
                            <p class="bStat"><%= FollwersCount %></p>
                        </div>
                        <div class="col-lg-3">
                            <p class="basic">Following</p>
                            <p class="bStat"><%= FollowingCount %></p>
                        </div>
                        <div class="col-lg-3">
                            <p class="basic">Join Date</p>
                            <p class="bStat"><%= Date %></p>
                        </div>
                    </div>

                    <div id="tweets" class="row">
                        <div class="col-lg-6">
                            <p class="tweet-title">Latest Tweet</p>
                            <p class="tweet-text"><%= latestText %></p>
                        </div>
                        <div class="col-lg-6">
                            <p class="tweet-title">Most Popular Tweet</p>
                            <p class="tweet-text"><%= popText %></p>
                        </div>
                    </div>

                    <div class="tweet-vals row">
                        <div class="tweet-favs col-lg-3">
                            <p class="val-favs"><%= latestFavs %></p>
                            <p class="val-type">Likes</p>
                        </div>
                        <div class="tweet-rts col-lg-3">
                            <p class="val-rts"><%= lastestRTs %></p>
                            <p class="val-type">Retweets</p>
                        </div>
                        <div class="tweet-favs col-lg-3">
                            <p class="val-favs"><%= popFavs %></p>
                            <p class="val-type">Likes</p>
                        </div>
                        <div class="tweet-rts col-lg-3">
                            <p class="val-rts"><%= PopRts %></p>
                            <p class="val-type">Retweets</p>
                        </div>
                    </div>

                    <div id="wordcloud-cont" class="row">
                        <p id="wordcloud-title">WordCloud of Word Frequency</p>
                        <div id="wordcloud" class="col-lg-12"></div>
                    </div>

                    <div id="hashtag-cont" style="width: 50%; height: 500px; float: left; display: inline;">
                        <p id="hashtags-title">Hashtags Count</p>
                        <canvas id="hashtags"></canvas>
                    </div>

                    <div id="mentions-cont" style="width: 50%; height: 500px; float: right; display: inline;">
                        <p id="mentions-title">Mentions Count</p>
                        <canvas id="mentions"></canvas>
                    </div>
                </form>
            </div>

        </div>

        <div id="nav">
            <ul id="nav-content">
                <li><a href="Viewer.aspx">Home</a></li>
                <li><a href="#">Search</a></li>
                <li><a href="#">Edit Account</a></li>
                <li id="manage" runat="server"><a href="Manage/Manage.aspx">Manage Users</a></li>
            </ul>
        </div>
    </div>
    <script src="http://d3js.org/d3.v3.min.js"></script>
    <script src="../scripts/d3.layout.cloud.js"></script>
    <script>
        var fill = d3.scale.category20();
        var width = 1260,
            height = 600;

        var keys = <%= tweetsJsonKeys %>;
        var vals = <%= tweetsJsonVals %>;
        var color = d3.scale.linear()
            .domain([0,1,2,3,4,5,6,10,15,20,100])
            .range(["#eee", "#d8e3ec", "#b6d4eb", "#8fc1e8", "#69afe5", "#47a0e0", "#3498db", "#3498d2", "#3499c8", "#39a7af", "#41aea4", "#45b29d"]);
        var maxCount = d3.max(vals);
        var scale = d3.scale.linear().domain([2, maxCount]).range([8, 70]); 
        var arr = d3.zip(keys, vals)
            .map(function(d) {return { text: d[0], size: scale(d[1]) }; });
        arr.slice(0,100);
        d3.layout.cloud()
            .size([width, height])
            .words(arr)
            .padding(8)
            .rotate(function () { return 0 })
            .fontSize(function (d) { return d.size; })
            .on("end", draw)
            .start();

        function draw(words) {
            d3.select("#wordcloud").append("svg")
                .attr("width", width)
                .attr("height", height)
                .append("g")
                .attr("transform", "translate(" + (width / 2) + "," + (height / 2) + ")")
                .selectAll("text")
                .data(words)
                .enter().append("text")
                .style("font-size", function (d) { return d.size + "px"; })
                .style("font-family", "Varela Round")
                .style("fill", function (d, i) { return color(i); })
                .attr("text-anchor", "middle")
                .attr("transform", function (d) {
                    return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
                })
                .text(function (d) { return d.text; });
        }
    </script>

    <script>
        var data = {
            labels: <%= hashJsonKeys %>,
            datasets: [
                {
                    label: "Count",
                    backgroundColor: "rgba(52,152,219,1)",
                    hoverBackgroundColor: "rgba(69,178,157,1)",
                    data: <%= hashJsonVals %>,
                }
            ]
        };
            var options = {
                scales: {
                    yAxes: [{
                        gridLines: {
                            lineWidth: 0,
                            color: "rgba(255,255,255,0)"
                        }
                    }],
                    xAxes: [{
                        gridLines: {
                            lineWidth: 0,
                            color: "rgba(255,255,255,0)"
                        }
                    }]
                },
                responsive: true
            }

            var chart = document.getElementById("hashtags").getContext("2d");
            var barchart1 = new Chart(chart, { type: "bar", data, options });           
            
    </script>

    <script>
        var data2 = {
            labels: <%= mentionsJsonKeys %>,
            datasets: [
                {
                    label: "Count",
                    backgroundColor: "rgba(52,152,219,1)",
                    hoverBackgroundColor: "rgba(69,178,157,1)",
                    data: <%= mentionsJsonVals %>,
                }
            ]
        };
            var options2 = {
                scales: {
                    yAxes: [{
                        gridLines: {
                            lineWidth: 0,
                            color: "rgba(255,255,255,0)"
                        }
                    }],
                    xAxes: [{
                        gridLines: {
                            lineWidth: 0,
                            color: "rgba(255,255,255,0)"
                        }
                    }]
                },
                responsive: true
            }
            var chart2 = document.getElementById("mentions").getContext("2d");
            var barchart2 = new Chart(chart2, {
                type: 'bar',
                data: data2,
                options: options2
            });          
            
    </script>

</body>
</html>
