using System;
using System.Collections.Generic;
using System.Web.UI;
using TweetSharp;

namespace TermProject
{
    public partial class Viewer : Page
    {
        private readonly Crawler _crawler = new Crawler();

        protected void Page_Load(object sender, EventArgs e)
        {
            //
        }

        protected void btn_serach_Click(object sender, EventArgs e)
        {
            IEnumerable<TwitterStatus> tweets;
            //switch depending on type of input
            switch (tb_input.Text[0])
            {

                case '#':
                    //get tweets by search
                    tweets = _crawler.GetSearch(tb_input.Text, 100); 
                    break;
                case '@':
                    //get tweets by usertimeline
                    tweets = _crawler.GetUserTimeline(tb_input.Text, 200);
                    break;
                default:
                    tweets = _crawler.GetSearch(tb_input.Text, 100);
                    break;

            }
            //parse hashtags from tweets, then convert to a string for the "Order" func
            string hashtags = _crawler.HashtagToString(_crawler.GetHashtags(tweets));
            // send to process as a dictionary to order the occurances
            var list = _crawler.Order(hashtags);
            // print result into the div
            mydiv.InnerHtml = _crawler.PrintList(list); 
        }
    }
}