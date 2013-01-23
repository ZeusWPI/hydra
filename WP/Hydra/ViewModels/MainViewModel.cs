using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Net;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using Hydra.Resources;

namespace Hydra.ViewModels
{
    public class MainViewModel : INotifyPropertyChanged
    {
        private const string SchamperApi = "http://zeus.ugent.be/hydra/api/1.0/schamper/daily.xml";
     

        /// <summary>
        /// A collection for ItemViewModel objects.
        /// </summary>
        public ObservableCollection<NewsItemViewModel> NewsItems { get; private set; }
        public ObservableCollection<ActivityItemsViewModel> ActivityItems { get; private set; }
        public ObservableCollection<SchamperItemsViewModel> SchamperItems { get; private set; }
        public ObservableCollection<InfoItemsViewModel> InfoItems { get; private set; }
        public ObservableCollection<RestoItemsViewModel> RestoItems { get; private set; }
       
        public MainViewModel()
        {
            this.NewsItems = new ObservableCollection<NewsItemViewModel>();
            this.ActivityItems=new ObservableCollection<ActivityItemsViewModel>();
            this.SchamperItems=new ObservableCollection<SchamperItemsViewModel>();
            this.InfoItems=new ObservableCollection<InfoItemsViewModel>();
            this.RestoItems=new ObservableCollection<RestoItemsViewModel>();
        }

        public bool IsDataLoaded
        {
            get;
            private set;
        }

        /// <summary>
        /// Creates and adds a few ItemViewModel objects into the NewsItems collection.
        /// </summary>
        public void LoadData()
        {
            var fetch=new WebClient();
            fetch.DownloadStringAsync(new Uri(SchamperApi));
            fetch.DownloadStringCompleted += ProcessSchamper;

         

            this.IsDataLoaded = true;
        }


        public void ProcessSchamper(object sender, DownloadStringCompletedEventArgs e)
        {
            if (e.Error != null || e.Cancelled) return;
            XElement resultElements = XElement.Parse(e.Result);

            var xElement = resultElements.Element(XName.Get("channel"));
            if (xElement != null)
                foreach (var schamperItem in xElement.Elements())
                {
                    if(schamperItem.Name=="item")
                    {
                        var dc = XNamespace.Get("http://purl.org/dc/elements/1.1/");
                        string date=null,author = null, title = null, image = null, content = null;
                        var element = schamperItem.Element(dc+"creator");
                        if (element != null)
                        {
                            author = element.Value;
                        }
                        element = schamperItem.Element("pubDate");
                        if (element != null)
                        {
                            date = element.Value;
                        }
                        element = schamperItem.Element(XName.Get("title"));
                        if (element != null)
                        {
                            title = element.Value;
                        }
                        element = schamperItem.Element(XName.Get("description"));
                        if (element != null)
                        {
                            content = element.Value;
                            string[] inputs = {content};
                            const string pattern = @"(https?:)?//?[^''""<>]+?\.(jpg|jpeg|gif|png)";
                            //@"(https?:\/\/.*\.(?:png|jpg|jpeg|gif))";

                            var rgx = new Regex(pattern, RegexOptions.IgnoreCase);

                            foreach (string input in inputs)
                            {
                                MatchCollection matches = rgx.Matches(input);
                                if (matches.Count > 0)
                                {
                                    foreach (Match match in matches)
                                        image=match.Value;
                                }
                            }


                        }
                        if (SchamperItems != null)
                            SchamperItems.Add(new SchamperItemsViewModel {Author = author,Content = content,ImagePath = image,Title = title,Date = date});
                    }
                }
        }

        public event PropertyChangedEventHandler PropertyChanged;
        private void NotifyPropertyChanged(String propertyName)
        {
            PropertyChangedEventHandler handler = PropertyChanged;
            if (null != handler)
            {
                handler(this, new PropertyChangedEventArgs(propertyName));
            }
        }
    }
}