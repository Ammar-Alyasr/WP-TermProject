using System.Collections.Generic;
using System.Linq;

namespace TermProject
{
    public class DataByTime
    {
        public List<string> MonthList;
        public List<int> ValueList;
        public List<int> Count;

        public DataByTime()
        {
            MonthList = new List<string>();
            ValueList = new List<int>();
            Count = new List<int>();
        }

        public DataByTime(List<string> month , List<int> vals, List<int> count)
        {
            MonthList = month;
            ValueList = vals;
            Count = count;
        }

        public string TweetsPer(DataByTime input)
        {
            double x = input.Count.Sum();
            x /= input.MonthList.Count;
            return $"{x:N2}";
        }
    }
}