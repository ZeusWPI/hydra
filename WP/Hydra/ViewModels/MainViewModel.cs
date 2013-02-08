using System.IO;
using System.Runtime.Serialization.Json;
using System.Text;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Net;
using System.Text.RegularExpressions;
using System.Xml.Linq;

namespace Hydra.ViewModels
{
    public class MainViewModel : INotifyPropertyChanged
    {
        private const string SchamperApi = "http://zeus.ugent.be/hydra/api/1.0/schamper/daily.xml";
        private const string ActivityApi = "http://student.ugent.be/hydra/api/1.0/all_activities.json";
        private const string NewsApi = "http://student.ugent.be/hydra/api/1.0/all_news.json";
        private const string RestoApi = "";
        
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
            NewsItems = new ObservableCollection<NewsItemViewModel>();
            ActivityItems=new ObservableCollection<ActivityItemsViewModel>();
            SchamperItems=new ObservableCollection<SchamperItemsViewModel>();
            InfoItems=new ObservableCollection<InfoItemsViewModel>();
            RestoItems=new ObservableCollection<RestoItemsViewModel>();
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
            LoadNews();
            LoadActivities();
            LoadSchamper();
            LoadInfo();
         

            IsDataLoaded = true;
        }

        public void LoadSchamper()
        {
            var fetch = new WebClient();
            fetch.DownloadStringAsync(new Uri(SchamperApi));
            fetch.DownloadStringCompleted += ProcessSchamper;
            IsDataLoaded = false;
        }

        public void LoadNews()
        {
            var fetch = new WebClient();
            fetch.DownloadStringAsync(new Uri(NewsApi));
            fetch.DownloadStringCompleted += ProcessNews;
            IsDataLoaded = false;
        }

        public void LoadActivities()
        {
            var fetch = new WebClient();
            fetch.DownloadStringAsync(new Uri(ActivityApi));
            fetch.DownloadStringCompleted += ProcessActivities;
            IsDataLoaded = false;
        }
        public void LoadResto()
        {
            throw new NotImplementedException();
        }


        public void ProcessNews(object sender, DownloadStringCompletedEventArgs e)
        {
             var ms = new MemoryStream(Encoding.UTF8.GetBytes(e.Result));
             var serializer = new DataContractJsonSerializer(typeof(ObservableCollection<NewsItemViewModel>));
                var list = (ObservableCollection<NewsItemViewModel>)serializer.ReadObject(ms);

            foreach (var newsItemView in list)
            {
                NewsItems.Add(newsItemView);
            }
            IsDataLoaded = true;

        }

        public void ProcessActivities(object sender, DownloadStringCompletedEventArgs e)
        {
            var ms = new MemoryStream(Encoding.UTF8.GetBytes(e.Result));
            var serializer = new DataContractJsonSerializer(typeof(ObservableCollection<ActivityItemsViewModel>));
            var list = (ObservableCollection<ActivityItemsViewModel>)serializer.ReadObject(ms);

            foreach (var newsItemView in list)
            {
                ActivityItems.Add(newsItemView);
            }
            IsDataLoaded = true;
        }


        public void LoadInfo()
        {
            
                var document = XElement.Load("Resources/info-content.plist");


                foreach (var element in document.Elements())
                {
                    if (element.Name == "array")
                    {
                        foreach (var dict in element.Elements(XName.Get("dict")))
                        {
                            string title = null, imagePath = null, link = null;
                            var subcontent = new List<InfoItemsViewModel>();
                            foreach (var node in dict.Elements())
                            {
                               
                                var el=(XElement)node.NextNode;
                                if (el != null && node.Value == "title")
                                {
                                    
                                    title = el.Value;
                                }
                                if (el != null && node.Value == "image")
                                {

                                    imagePath = el.Value+"@2x";
                                }
                                if (el != null && node.Value == "html")
                                {

                                    link = el.Value;
                                }

                                if (node.Value == "subcontent")
                                {
                                    if (el != null)
                                        subcontent.AddRange(from subcon in el.Elements("dict") select subcon.Element("key") into xElement where xElement != null select new InfoItemsViewModel {Title = ((XElement) xElement.NextNode).Value, Link = ((XElement) xElement.NextNode.NextNode.NextNode).Value});
                                }

                            }
                            InfoItems.Add(new InfoItemsViewModel {Children = subcontent,ImagePath = imagePath,Link = link,Title = title});
                            
                        }
                    }
                }
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
            IsDataLoaded = true;
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