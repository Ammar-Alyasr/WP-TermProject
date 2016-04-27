using System;
using System.Collections.Generic;
using System.Web.UI;
using TweetSharp;

namespace TermProject
{
    public partial class Viewer : Page
    {
        private readonly Crawler _crawler = new Crawler();

        protected void btn_serach_Click(object sender, EventArgs e)
        {
            var tweets = _crawler.GetUserTimeline(tb_input.Text, int.Parse(tb_count.Text));
            string output = "";
            int count = 0;
            foreach (var tweet in tweets)
            {
                count++;
                output += count + ": " + tweet.CreatedDate + " - " + tweet.Text + "<br />";
            }
            mydiv.InnerHtml = output;
        }
    }
}