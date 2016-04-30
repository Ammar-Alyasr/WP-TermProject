using System;
using System.Web.UI;


namespace TermProject
{
    public partial class Viewer : Page
    {
        private static readonly Crawler _crawler = new Crawler();

        public string ProfileUrl = _crawler.GetUserProfileImage("browns");
        public string Name = _crawler.GetUserName("browns");
        public string BannerUrl = _crawler.GetBannerURL("browns");

        protected void btn_serach_Click(object sender, EventArgs e)
        {
            var tweets = _crawler.GetUserTimeline(tb_input.Text, int.Parse(tb_count.Text));
            var list = _crawler.OrderWithCutouff(_crawler.StatusToString(tweets), 10);

            mydiv.InnerHtml = _crawler.PrintList(list);
        }
    }
}