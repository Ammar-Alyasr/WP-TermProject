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
                            <p class="tweet-text"><%= LatestText %></p>
                        </div>
                        <div class="col-lg-6">
                            <p class="tweet-title">Most Popular Tweet</p>
                            <p class="tweet-text"><%= PopText %></p>
                        </div>
                    </div>

                    <div class="tweet-vals row">
                        <div class="tweet-favs col-lg-3">
                            <p class="val-favs"><%= LatestFavs %></p>
                            <p class="val-type">Likes</p>
                        </div>
                        <div class="tweet-rts col-lg-3">
                            <p class="val-rts"><%= LastestRTs %></p>
                            <p class="val-type">Retweets</p>
                        </div>
                        <div class="tweet-favs col-lg-3">
                            <p class="val-favs"><%= PopFavs %></p>
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

                    <div id="line-cont" style="width: 100%; height: 500px;">
                        <p id="line-title">Tweet Stats Over Time</p>
                        <button id="monthBtn" onclick="return false">By Month</button>
                        <button id="daysBtn" onclick="return false">By Day</button>
                        <div id="canvas-cont"></div>
                    </div>

                    <div id="averages" class="row">
                        <div class="col-lg-3">
                            <p class="avg-title">Average Likes Per Tweet</p>
                            <p class="avg-val"><%= AvgFavs %></p>
                        </div>
                        <div class="col-lg-3">
                            <p class="avg-title">Average Retweets Per Tweet</p>
                            <p class="avg-val"><%= AvgRts %></p>
                        </div>
                         <div class="col-lg-3">
                            <p class="avg-title">Average Tweets Per Day</p>
                            <p class="avg-val"><%= AvgDay %></p>
                        </div>
                         <div class="col-lg-3">
                            <p class="avg-title">Average Tweets Per Month</p>
                            <p class="avg-val"><%= AvgMonth %></p>
                        </div>
                    </div>

                    <div id="donut-cont" style="width: 100%; height: 500px;">
                        <div id="donut-hour" style="width: 50%; float: left; display: inline;">
                            <p class="donut-title">Tweets by Hour</p>
                            <canvas id="donut1"></canvas>
                        </div>
                        <div id="donut-day" style="width: 50%; float: right; display: inline;">
                            <p class="donut-title">Tweets by Day</p>
                            <canvas id="donut2"></canvas>
                        </div>
                    </div>

                </form>
            </div>

        </div>

        <div id="nav">
            <ul id="nav-content">
                <li class="nav-select"><a href="#">Home</a></li>
                <li><a href="../Doc.aspx">Documentation</a></li>
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

        var keys = <%= TweetsJsonKeys %>;
        var vals = <%= TweetsJsonVals %>;
        var color = d3.scale.linear()
            .domain([0,1,2,3,4,5,6,10,15,20,100])
            .range(["#eee", "#d8e3ec", "#b6d4eb", "#8fc1e8", "#69afe5", "#47a0e0", "#3498db", "#3498d2", "#3499c8", "#39a7af", "#41aea4", "#45b29d"]);
        var maxCount = d3.max(vals);
        var scale = d3.scale.linear().domain([2, maxCount]).range([8, 70]); 
        var arr = d3.zip(keys, vals)
            .map(function(d) {
                return { text: d[0], size: scale(d[1]) }; 
                
            });
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
        var barData = {
            labels: <%= HashJsonKeys %>,
            datasets: [
                {
                    label: "Count",
                    backgroundColor: "rgba(52,152,219,0.4)",
                    borderColor: "rgba(52,152,219,1)",
                    borderWidth: 2,
                    hoverBackgroundColor: "rgba(69,178,157,0.4)",
                    hoverBorderColor: "rgba(69,178,157,1)",
                    data: <%= HashJsonVals %>,
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
            var barchart1 = new Chart(chart, {
                type: 'bar',
                data: barData,
                options: options
            });            
            
    </script>

    <script>
        var barData2 = {
            labels: <%= MentionsJsonKeys %>,
            datasets: [
                {
                    label: "Count",
                    backgroundColor: "rgba(52,152,219,0.4)",
                    borderColor: "rgba(52,152,219,1)",
                    borderWidth: 2,
                    hoverBackgroundColor: "rgba(69,178,157,0.4)",
                    hoverBorderColor: "rgba(69,178,157,1)",
                    data: <%= MentionsJsonVals %>,
                }
            ]
        };
            var chart2 = document.getElementById("mentions").getContext("2d");
            var barchart2 = new Chart(chart2, {
                type: 'bar',
                data: barData2,
                options: options
            });          
            
    </script>

    <script>
        var canvas_html = '<canvas id="line"></canvas>';

        $(document).ready(function(){

            drawChart(lineData1());
            $("#monthBtn").click(function() {
                drawChart(lineData1());
            });

            $("#daysBtn").click(function(){
                drawChart(lineData2());
            });
        });
    
        var drawChart = function(data) {
            $('#canvas-cont').html(canvas_html);

            var lineChart = document.getElementById("line").getContext("2d");
            var lChart = new Chart(lineChart, {
                type: 'line',
                data: data
            }); 
        };
    </script>
    <script>
        var lineData1 = function() {
            return {
                labels: <%= FavsJsonKeys %>,
                datasets: [
                    {
                        label: "Likes",
                        fill: false,
                        lineTension: 0.1,
                        backgroundColor: "rgba(75,192,192,0.4)",
                        borderColor: "rgba(75,192,192,1)",
                        borderCapStyle: 'butt',
                        borderDash: [],
                        borderDashOffset: 0.0,
                        borderJoinStyle: 'round',
                        pointBorderColor: "rgba(75,192,192,1)",
                        pointBackgroundColor: "#fff",
                        pointBorderWidth: 1,
                        pointHoverRadius: 5,
                        pointHoverBackgroundColor: "rgba(75,192,192,1)",
                        pointHoverBorderColor: "rgba(220,220,220,1)",
                        pointHoverBorderWidth: 1,
                        pointRadius: 1,
                        pointHitRadius: 10,
                        data: <%= FavsJsonVals %>,
                    },
                    {
                        label: "Retweets",
                        fill: false,
                        lineTension: 0.1,
                        backgroundColor: "rgba(52, 152, 219,.4)",
                        borderColor: "rgba(52, 152, 219,1)",
                        borderCapStyle: 'butt',
                        borderDash: [],
                        borderDashOffset: 0.0,
                        borderJoinStyle: 'round',
                        pointBorderColor: "rgba(52, 152, 219,1)",
                        pointBackgroundColor: "#fff",
                        pointBorderWidth: 1,
                        pointHoverRadius: 5,
                        pointHoverBackgroundColor: "rgba(52, 152, 219,1)",
                        pointHoverBorderColor: "rgba(220,220,220,1)",
                        pointHoverBorderWidth: 1,
                        pointRadius: 1,
                        pointHitRadius: 10,
                        data: <%= RtsJsonVals %>,
                    },
                    {
                        label: "Tweets",
                        fill: false,
                        lineTension: 0.1,
                        backgroundColor: "rgba(239,201,76,.4)",
                        borderColor: "rgba(239,201,76,1)",
                        borderCapStyle: 'butt',
                        borderDash: [],
                        borderDashOffset: 0.0,
                        borderJoinStyle: 'round',
                        pointBorderColor: "rgba(239,201,76,1)",
                        pointBackgroundColor: "#fff",
                        pointBorderWidth: 1,
                        pointHoverRadius: 5,
                        pointHoverBackgroundColor: "rgba(239,201,76,1)",
                        pointHoverBorderColor: "rgba(220,220,220,1)",
                        pointHoverBorderWidth: 1,
                        pointRadius: 1,
                        pointHitRadius: 10,
                        data: <%= CountJson %>,
                    }
                ]
            };
        };
            var lineData2 = function() {
                return {
                    labels: <%= FavsJsonKeysAlt %>,
                datasets: [
                    {
                        label: "Likes",
                        fill: false,
                        lineTension: 0.1,
                        backgroundColor: "rgba(75,192,192,0.4)",
                        borderColor: "rgba(75,192,192,1)",
                        borderCapStyle: 'butt',
                        borderDash: [],
                        borderDashOffset: 0.0,
                        borderJoinStyle: 'round',
                        pointBorderColor: "rgba(75,192,192,1)",
                        pointBackgroundColor: "#fff",
                        pointBorderWidth: 1,
                        pointHoverRadius: 5,
                        pointHoverBackgroundColor: "rgba(75,192,192,1)",
                        pointHoverBorderColor: "rgba(220,220,220,1)",
                        pointHoverBorderWidth: 1,
                        pointRadius: 1,
                        pointHitRadius: 10,
                        data: <%= FavsJsonValsAlt %>,
                    },
                    {
                        label: "Retweets",
                        fill: false,
                        lineTension: 0.1,
                        backgroundColor: "rgba(52, 152, 219,.4)",
                        borderColor: "rgba(52, 152, 219,1)",
                        borderCapStyle: 'butt',
                        borderDash: [],
                        borderDashOffset: 0.0,
                        borderJoinStyle: 'round',
                        pointBorderColor: "rgba(52, 152, 219,1)",
                        pointBackgroundColor: "#fff",
                        pointBorderWidth: 1,
                        pointHoverRadius: 5,
                        pointHoverBackgroundColor: "rgba(52, 152, 219,1)",
                        pointHoverBorderColor: "rgba(220,220,220,1)",
                        pointHoverBorderWidth: 1,
                        pointRadius: 1,
                        pointHitRadius: 10,
                        data: <%= RtsJsonValsAlt %>,
                    },
                    {
                        label: "Tweets",
                        fill: false,
                        lineTension: 0.1,
                        backgroundColor: "rgba(239,201,76,.4)",
                        borderColor: "rgba(239,201,76,1)",
                        borderCapStyle: 'butt',
                        borderDash: [],
                        borderDashOffset: 0.0,
                        borderJoinStyle: 'round',
                        pointBorderColor: "rgba(239,201,76,1)",
                        pointBackgroundColor: "#fff",
                        pointBorderWidth: 1,
                        pointHoverRadius: 5,
                        pointHoverBackgroundColor: "rgba(239,201,76,1)",
                        pointHoverBorderColor: "rgba(220,220,220,1)",
                        pointHoverBorderWidth: 1,
                        pointRadius: 1,
                        pointHitRadius: 10,
                        data: <%= CountJsonAlt %>,
                    }
                ]
            };
        };

    </script>

    <script>
        var donutData = {
            labels: <%= HoursKeys %>,
            datasets: [
            {
                data: <%= HoursVals %>,
                backgroundColor: [
                    "#1abc9c",
                    "#16a085",
                    "#2ecc71",
                    "#27ae60",
                    "#3498db",
                    "#2980b9",
                    "#9b59b6",
                    "#8e44ad",
                    "#34495e",
                    "#2c3e50",
                    "#f1c40f",
                    "#f39c12",
                    "#e67e22",
                    "#d35400",
                    "#e74c3c",
                    "#c0392b",
                    "#ecf0f1",
                    "#bdc3c7",
                    "#95a5a6",
                    "#7f8c8d",

                ],
                hoverBackgroundColor: [
                    "#1abc9c",
                    "#16a085",
                    "#2ecc71",
                    "#27ae60",
                    "#3498db",
                    "#2980b9",
                    "#9b59b6",
                    "#8e44ad",
                    "#34495e",
                    "#2c3e50",
                    "#f1c40f",
                    "#f39c12",
                    "#e67e22",
                    "#d35400",
                    "#e74c3c",
                    "#c0392b",
                    "#ecf0f1",
                    "#bdc3c7",
                    "#95a5a6",
                    "#7f8c8d",
                ],
                borderColor: [
                    "#1abc9c",
                    "#16a085",
                    "#2ecc71",
                    "#27ae60",
                    "#3498db",
                    "#2980b9",
                    "#9b59b6",
                    "#8e44ad",
                    "#34495e",
                    "#2c3e50",
                    "#f1c40f",
                    "#f39c12",
                    "#e67e22",
                    "#d35400",
                    "#e74c3c",
                    "#c0392b",
                    "#ecf0f1",
                    "#bdc3c7",
                    "#95a5a6",
                    "#7f8c8d",
                ]
            }]
        };

        var chart4 = document.getElementById("donut1").getContext("2d");
        var myDoughnutChart = new Chart(chart4, {
            type: 'doughnut',
            data: donutData
        });
    </script>
    <script>
        var donutData2 = {
            labels: <%= DaysKeys %>,
            datasets: [
            {
                data: <%= DaysVals %>,
                backgroundColor: [
                    "#1abc9c",
                    "#16a085",
                    "#2ecc71",
                    "#27ae60",
                    "#3498db",
                    "#2980b9",
                    "#9b59b6",
                    "#8e44ad",
                    "#34495e",
                    "#2c3e50",
                    "#f1c40f",
                    "#f39c12",
                    "#f1c40f",
                    "#d35400",
                    "#e74c3c",
                    "#c0392b",
                    "#ecf0f1",
                    "#bdc3c7",
                    "#95a5a6",
                    "#7f8c8d",

                ],
                hoverBackgroundColor: [
                    "#1abc9c",
                    "#16a085",
                    "#2ecc71",
                    "#27ae60",
                    "#3498db",
                    "#2980b9",
                    "#9b59b6",
                    "#8e44ad",
                    "#34495e",
                    "#2c3e50",
                    "#f1c40f",
                    "#f39c12",
                    "#f1c40f",
                    "#d35400",
                    "#e74c3c",
                    "#c0392b",
                    "#ecf0f1",
                    "#bdc3c7",
                    "#95a5a6",
                    "#7f8c8d",
                ],
                borderColor: [
                    "#1abc9c",
                    "#16a085",
                    "#2ecc71",
                    "#27ae60",
                    "#3498db",
                    "#2980b9",
                    "#9b59b6",
                    "#8e44ad",
                    "#34495e",
                    "#2c3e50",
                    "#f1c40f",
                    "#f39c12",
                    "#f1c40f",
                    "#d35400",
                    "#e74c3c",
                    "#c0392b",
                    "#ecf0f1",
                    "#bdc3c7",
                    "#95a5a6",
                    "#7f8c8d",
                ]
            }]
        };

        var chart5 = document.getElementById("donut2").getContext("2d");
        var myDoughnutChart = new Chart(chart5, {
            type: 'doughnut',
            data: donutData2
        });
    </script>
</body>
</html>
