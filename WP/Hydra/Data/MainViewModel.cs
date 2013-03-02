using System.Globalization;
using System.IO;
using System.IO.IsolatedStorage;
using System.Runtime.Serialization.Json;
using System.Text;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Net;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Threading;
using System.Xml.Linq;
using Facebook;
using Microsoft.Phone.Net.NetworkInformation;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;

namespace Hydra.Data
{
    public class MainViewModel : INotifyPropertyChanged
    {
        private const string SchamperApi = "http://zeus.ugent.be/hydra/api/1.0/schamper/daily.xml";
        private const string ActivityApi = "http://student.ugent.be/hydra/api/1.0/all_activities.json";
        private const string NewsApi = "http://student.ugent.be/hydra/api/1.0/all_news.json";
        private const string RestoApi = "http://zeus.ugent.be/hydra/api/1.0/resto/week/";
        private const string MetaApi = "http://zeus.ugent.be/hydra/api/1.0/resto/meta.json";
        private const string ConnectionString = "isostore:/settings.sdf";
        private bool _news, _activity, _schamper, _info, _resto, _meta, _asso;
        private bool _fromCache;
        private int _offset, _week;
        private DateTime _cacheTime;
        private const string AppId = "146947948791011";
        private const string GenericAccessToken = "146947948791011|QqOR99OREkC_vAvOkfJm2tp-02k";
        private const string ExtendedPermissions = "user_about_me,rsvp_event";
        private readonly FacebookClient _fb = new FacebookClient();
        private readonly IsolatedStorageFile _isoStore = IsolatedStorageFile.GetUserStoreForApplication();

        /// <summary>
        /// A collection for ItemViewModel objects.
        /// </summary>
        public ObservableCollection<NewsItemViewModel> NewsItems { get; private set; }
        public ObservableCollection<ActivityItemsViewModel> ActivityItems { get; private set; }
        public ObservableCollection<SchamperItemsViewModel> SchamperItems { get; private set; }
        public ObservableCollection<InfoItemsViewModel> InfoItems { get; private set; }
        public ObservableCollection<RestoItemsViewModel> RestoItems { get; private set; }
        public List<Association> Associtions { get; private set; }
        public MetaResto MetaRestoItem { get; private set; }

        public string Appid
        {
            get { return AppId; }
        }

        public string GenericId { get { return GenericAccessToken; } }

        public MainViewModel()
        {
            InfoItems = new ObservableCollection<InfoItemsViewModel>();
            Associtions = new List<Association>();
            NewsItems = new ObservableCollection<NewsItemViewModel>();
            ActivityItems = new ObservableCollection<ActivityItemsViewModel>();
            SchamperItems = new ObservableCollection<SchamperItemsViewModel>();
            RestoItems = new ObservableCollection<RestoItemsViewModel>();
            _offset = 0;
            _fromCache = false;
            UserPreference = new UserPreference();
        }

        public Uri FacebookLoginUrl(string uri)
        {
            var parameters = new Dictionary<string, object>();
            parameters["client_id"] = AppId;
            parameters["redirect_uri"] = uri;
            parameters["response_type"] = "token";
            parameters["display"] = "touch";

            // add the 'scope' only if we have extendedPermissions.
            if (!string.IsNullOrEmpty(ExtendedPermissions))
            {
                // A comma-delimited list of permissions
                parameters["scope"] = ExtendedPermissions;
            }

            return _fb.GetLoginUrl(parameters);
        }

        public Uri FacebookLogOutUrl(string uri)
        {
            var parameters = new Dictionary<string, object>();
            parameters["client_id"] = AppId;
            parameters["redirect_uri"] = uri;
            parameters["display"] = "touch";

            return _fb.GetLogoutUrl(parameters);
        }

        public UserPreference UserPreference { get; set; }

        public bool HasConnection
        {
            get
            {
                return NetworkInterface.NetworkInterfaceType != NetworkInterfaceType.None;
            }
        }


        public bool IsDataLoaded
        {
            get { return _news && _activity && _schamper && _info && _resto && _meta && _asso; }
        }

        public bool IsEssentialsLoaded
        {
            get { return _info && _asso; }

        }


        /// <summary>
        /// Creates and adds the data to the viewmodels
        /// </summary>
        public async void LoadData(bool reload)
        {
            if (!IsEssentialsLoaded)
            {

                LoadInfo();
                LoadAssociations();
                LoadSettings();
                try
                {
                    await LoadFaceBookSettings();
                }
                catch (Exception)
                {
                    //NIET INGELOGD
                }
            }
            if (!reload) return;
            RestoItems.Clear();
            NewsItems.Clear();
            ActivityItems.Clear();
            SchamperItems.Clear();
            _fromCache = DateTime.Now.AddMinutes(-60) < _cacheTime;
            if (!_fromCache && !HasConnection)
                _fromCache = true;
            LoadNews();
            LoadResto();
            LoadActivities();
            LoadSchamper();
            
        }

        private async Task<bool> LoadFaceBookSettings()
        {
            var res = false;
            if (UserPreference.AccessKey == null || !HasConnection) return false;
            var fb = new FacebookClient(UserPreference.AccessKey);
            fb.GetCompleted += (o, e) =>
                                   {
                                       if (e.Error != null)
                                       {
                                           UserPreference.AccessKey = null;
                                           UserPreference.Name = null;
                                           UserPreference.FbUserId = null;
                                           SaveSettings();
                                           res = false;
                                           return;
                                       }

                                       var result = (IDictionary<string, object>)e.GetResultData();
                                       UserPreference.FbUserId = (string)result["id"];
                                       UserPreference.Name = (string)result["name"];
                                       res = true;
                                   };
            try
            {
                await fb.GetTaskAsync("me");
            }
            catch(Exception)
            {
                UserPreference.AccessKey = null;
                UserPreference.Name = null;
                UserPreference.FbUserId = null;
                res = false;
            }
            return res;
        }

        private void LoadSettings()
        {
            using (var context = new Settings(ConnectionString))
            {

                if (!context.DatabaseExists())
                {
                    // create database if it does not exist
                    try
                    {
                        context.CreateDatabase();
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine(e.Data);
                    }
                }
                else
                {
                    var query = context.SettingsTable.Where(setting => setting.Id == 0);
                    if (!query.Any())
                    {
                        SaveSettings();
                        return;
                    }
                    var sett = query.First();
                    UserPreference.IsFiltering = bool.Parse(sett.Filtering);
                    _cacheTime = DateTime.Parse(sett.CacheDate, new CultureInfo("nl-BE"));
                    UserPreference.AccessKey = sett.AccessKey;
                    UserPreference.FbUserId = sett.FbUserId;
                    UserPreference.Name = sett.Name;
                    if (sett.Associations.Equals("")) return;
                    foreach (var asso in new List<string>(sett.Associations.Split(';')))
                    {
                        var i = 0;
                        while (i < Associtions.Count && Associtions[i].In != asso)
                        {
                            i++;
                        }
                        if (i < Associtions.Count)
                            UserPreference.PreferredAssociations.Add(Associtions[i]);
                    }

                }
            }
        }



        public void SaveSettings()
        {
            using (var context = new Settings(ConnectionString))
            {

                if (!context.DatabaseExists())
                {
                    // create database if it does not exist
                    context.CreateDatabase();
                }
                var query = context.SettingsTable.Where(setting => setting.Id == 0);
                string s = null;
                s = UserPreference.PreferredAssociations.Aggregate(s, (current, preferredAssociation) => current + (preferredAssociation.In + ';'));
                var formatted = s != null ? s.Substring(0, s.Length - 1) : "";
                SettingsTable settingUpdate = null;
                if (query.Any())
                {
                    settingUpdate = query.First();
                }
                if (!query.Any())
                {
                    var sett = new SettingsTable { Associations = formatted, Filtering = Convert.ToString(UserPreference.IsFiltering), Id = 0, CacheDate = _cacheTime.ToString(new CultureInfo("nl-BE")), AccessKey = UserPreference.AccessKey, FbUserId = UserPreference.FbUserId, Name = UserPreference.Name };
                    context.SettingsTable.InsertOnSubmit(sett);

                }
                else
                {

                    if (settingUpdate != null)
                    {
                        settingUpdate.Filtering = Convert.ToString(UserPreference.IsFiltering);
                        settingUpdate.Associations = formatted;
                        settingUpdate.CacheDate = _cacheTime.ToString(new CultureInfo("nl-BE"));
                        settingUpdate.AccessKey = UserPreference.AccessKey;
                        settingUpdate.FbUserId = UserPreference.FbUserId;
                        settingUpdate.Name = UserPreference.Name;
                    }
                }
                context.SubmitChanges();
            }
        }

        public void LoadSchamper()
        {
            if (!_fromCache || !_isoStore.FileExists("schamper.xml"))
            {
                var fetch = new WebClient();
                _schamper = false;
                fetch.DownloadStringCompleted += ProcessSchamper;
                fetch.DownloadStringAsync(new Uri(SchamperApi));
            }
            else
            {
                ProcessSchamper(null, null);
            }
        }

        public void LoadNews()
        {
            if (!_fromCache || !_isoStore.FileExists("news.json"))
            {
                var fetch = new WebClient();
                _news = false;
                fetch.DownloadStringCompleted += ProcessNews;
                fetch.DownloadStringAsync(new Uri(NewsApi));
            }
            else
            {
                ProcessNews(null, null);
            }
        }

        public  void LoadActivities()
        {
            if (!_fromCache || !_isoStore.FileExists("activities.json"))
            {
                var fetch = new WebClient();
                _activity = false;
                fetch.DownloadStringCompleted += ProcessActivities;
                fetch.DownloadStringAsync(new Uri(ActivityApi));
            }
            else
            {
                ProcessActivities(null, null);
            }


        }



        public void LoadResto()
        {
            _week = new CultureInfo("nl-BE").Calendar.GetWeekOfYear(DateTime.Now, CalendarWeekRule.FirstDay,
                                                                        DayOfWeek.Monday);

            if (!_fromCache || (!_isoStore.FileExists((_week + _offset) + ".json") || !_isoStore.FileExists("meta.json")))
            {
                var fetch = new WebClient();
                _resto = false;
                fetch.DownloadStringCompleted += ProcessResto;
                fetch.DownloadStringAsync(new Uri(RestoApi + (_week + _offset) + ".json"));
                if (_offset == 0)
                {
                    var meta = new WebClient();
                    meta.DownloadStringCompleted += ProcessMetaResto;
                    meta.DownloadStringAsync(new Uri(MetaApi));
                }
            }
            else
            {
                ProcessResto(null, null);
                ProcessMetaResto(null, null);
            }

        }

        void ProcessMetaResto(object sender, DownloadStringCompletedEventArgs e)
        {
            MemoryStream ms = null;
            if ((e == null && !_fromCache) || (e != null && (e.Error != null || e.Cancelled)))
            {
                _meta = true;
                return;
            }
            if (e == null && _fromCache)
                ms = new MemoryStream(Encoding.UTF8.GetBytes(LoadFromStorage("meta", ".json")));
            else if (e != null) ms = new MemoryStream(Encoding.UTF8.GetBytes(SaveToStorage("meta", ".json", e.Result)));
            var serializer = new DataContractJsonSerializer(typeof(MetaResto));
            if (ms != null)
            {
                var list = (MetaResto)serializer.ReadObject(ms);
                if (list == null) return;
                MetaRestoItem = list;
            }

            _meta = true;

        }

        public void ProcessResto(object sender, DownloadStringCompletedEventArgs e)
        {
            String ms = null;
            if ((e == null && !_fromCache) || (e != null && (e.Error != null || e.Cancelled)))
            {
                _resto = true;
                return;
            }
            if (e == null && _fromCache)
                ms = LoadFromStorage(Convert.ToString((_week + _offset)), ".json");
            else if (e != null) ms = SaveToStorage(Convert.ToString((_week + _offset)), ".json", e.Result);
            if (ms == null) return;
            var ob = (JObject)JsonConvert.DeserializeObject(ms);

            foreach (var day in ob)
            {
                if (DateTime.Parse(day.Key, new CultureInfo("nl-BE")).Date < DateTime.Now.Date) continue;
                bool open;
                try
                {
                    open = (bool)day.Value.ElementAt(1).ElementAt(0);
                }
                catch (Exception)
                {
                    //closed
                    RestoItems.Add(new RestoItemsViewModel { Day = new Day { IsOpen = false } });
                    continue;
                }
                var dishes = (from daydish in day.Value.ElementAt(0)
                              from ddish in daydish.Distinct()
                              select new Dish
                                         {
                                             Name = (string)ddish["name"],
                                             Price = (string)ddish["price"],
                                             IsRecommended = (bool)ddish["recommended"]
                                         }).ToList();

                var soup = day.Value.ElementAt(2).Values().Select(soupp => (string)soupp).ToList();
                var veg = day.Value.ElementAt(3).Values().Select(veggie => (string)veggie).ToList();
                if(dishes.Count<4)
                    dishes.Add(new Dish {IsRecommended = false,Name = "",Price = ""});
                if (RestoItems.Count < 7)
                    RestoItems.Add(new RestoItemsViewModel { Day = new Day { Dishes = dishes, Date = day.Key, Open = open, Soup = soup, Vegetables = veg ,IsOpen = true}});
                else if (RestoItems.Count >= 7)
                    break;
            }
            if (RestoItems.Count < 7)
            {
                _offset++;
                LoadResto();
            }
            _resto = true;


        }


        public void ProcessNews(object sender, DownloadStringCompletedEventArgs e)
        {
            MemoryStream ms = null;
            if ((e == null && !_fromCache) || (e != null && (e.Error != null || e.Cancelled)))
            {
                _news = true;
                return;
            }
            if (e == null && _fromCache)
                ms = new MemoryStream(Encoding.UTF8.GetBytes(LoadFromStorage("news", ".json")));
            else if (e != null) ms = new MemoryStream(Encoding.UTF8.GetBytes(SaveToStorage("news", ".json", e.Result)));
            var serializer = new DataContractJsonSerializer(typeof(ObservableCollection<NewsItemViewModel>));
            if (ms != null)
            {
                var list = (ObservableCollection<NewsItemViewModel>)serializer.ReadObject(ms);
                if (list == null) return;
                foreach (var newsItemView in list)
                {
                    NewsItems.Add(newsItemView);
                }
            }
            _news = true;
            NotifyPropertyChanged("GroupedNews");

        }

        public List<KeyedList<string, NewsItemViewModel>> GroupedNews
        {
            get
            {
                IEnumerable<KeyedList<string, NewsItemViewModel>> groupedNews;
                //if(!UserPreference.IsFiltering){
                    groupedNews =
                    from news in NewsItems
                    orderby DateTime.Parse(news.Date, new CultureInfo("nl-BE"))
                    group news by DateTime.Parse(news.Date, new CultureInfo("nl-BE")).ToString("ddd dd MMMM") into newsByDay
                    select new KeyedList<string, NewsItemViewModel>(newsByDay);
                //}
                //else
                //{
                //    groupedNews =
                //    from news in NewsItems where UserPreference.PreferredAssociations.Contains(news.Assocition)==true
                //    orderby DateTime.Parse(news.Date, new CultureInfo("nl-BE"))
                //    group news by DateTime.Parse(news.Date, new CultureInfo("nl-BE")).ToString("ddd dd MMMM") into newsByDay
                //    select new KeyedList<string, NewsItemViewModel>(newsByDay);
                //}

                return new List<KeyedList<string, NewsItemViewModel>>(groupedNews);
            }
        }



        public async void ProcessActivities(object sender, DownloadStringCompletedEventArgs e)
        {
            MemoryStream ms = null;
            if ((e == null && !_fromCache) || (e != null && (e.Error != null || e.Cancelled)))
            {
                _activity = true;
                return;
            }
            if (e == null && _fromCache)
                ms = new MemoryStream(Encoding.UTF8.GetBytes(LoadFromStorage("activities", ".json")));
            else if (e != null)
                ms = new MemoryStream(Encoding.UTF8.GetBytes(SaveToStorage("activities", ".json", e.Result)));
            var serializer = new DataContractJsonSerializer(typeof(ObservableCollection<ActivityItemsViewModel>));
            if (ms != null)
            {
                var list = (ObservableCollection<ActivityItemsViewModel>)serializer.ReadObject(ms);
                if (list == null) return;
                foreach (var activityItemView in list.Where(activityItemView => DateTime.Parse(activityItemView.StartDate, new CultureInfo("nl-BE")) >= DateTime.Now))
                {
                    ActivityItems.Add(activityItemView);
                }
            }
            _activity = true;
            NotifyPropertyChanged("GroupedActivities");

        }

      

        public List<KeyedList<string, ActivityItemsViewModel>> GroupedActivities
        {
            get
            {
                var groupedActivities =
                    from activity in ActivityItems
                    orderby DateTime.Parse(activity.StartDate, new CultureInfo("nl-BE"))
                    group activity by DateTime.Parse(activity.StartDate, new CultureInfo("nl-BE")).ToString("ddd dd MMMM") into activitiesByDay
                    select new KeyedList<string, ActivityItemsViewModel>(activitiesByDay);

                return new List<KeyedList<string, ActivityItemsViewModel>>(groupedActivities);
            }
        }

        public async void UnlinkFaceBook()
        {
            if(!HasConnection || UserPreference.AccessKey==null)
                return; 
            var fb = new FacebookClient(UserPreference.AccessKey) { AppId = AppId };
            await fb.DeleteTaskAsync(string.Format("https://graph.facebook.com/{0}/permissions", UserPreference.FbUserId));
            UserPreference.AccessKey = null;
            UserPreference.FbUserId = null;
            UserPreference.Name = null;
            SaveSettings();
            NotifyPropertyChanged("AccessKey");
        }

        public void LoadAssociations()
        {

            var document = XElement.Load("Resources/Associations.plist");


            foreach (var dict in from element in document.Elements() where element.Name == "array" from dict in element.Elements(XName.Get("dict")) select dict)
            {
                //                   <dict>
                //    <key>displayName</key>
                //    <string>Vlaamse Biomedische Kring</string>
                //    <key>internalName</key>
                //    <string>VBK</string>
                //    <key>parentAssociation</key>
                //    <string>FKCENTRAAL</string>
                //</dict>
                //<dict>
                //    <key>displayName</key>
                //    <string>ChiSAG</string>
                //    <key>fullName</key>
                //    <string>Chinese Student Association Ghent</string>
                //    <key>internalName</key>
                //    <string>CHISAG</string>
                //    <key>parentAssociation</key>
                //    <string>IKCENTRAAL</string>
                //</dict>
                foreach (var node in dict.Elements())
                {
                    string display = null, intern;
                    string parent;
                    Association asso = null;
                    var el = (XElement)node.NextNode;
                    if (node.Value.Equals("displayName")) display = el.Value;
                    el = (XElement)node.NextNode.NextNode;
                    if (el.Value.Equals("internalName"))
                    {
                        intern = ((XElement)el.NextNode).Value;
                        el = (XElement)el.NextNode.NextNode;
                        parent = ((XElement)el.NextNode).Value;
                        asso = new Association { In = intern, Fn = display, Dn = display, Parent = parent };
                    }
                    else if (el.Value.Equals("fullName"))
                    {
                        var full = ((XElement)el.NextNode).Value;
                        el = (XElement)el.NextNode.NextNode;
                        intern = ((XElement)el.NextNode).Value;
                        el = (XElement)el.NextNode.NextNode;
                        parent = ((XElement)el.NextNode).Value;
                        asso = new Association { In = intern, Fn = full, Dn = display, Parent = parent };
                    }
                    if (asso != null)
                        Associtions.Add(asso);
                    break;

                }
            }
            _asso = true;

        }


        public void LoadInfo()
        {

            var document = XElement.Load("Resources/info-content.plist");


            foreach (var dict in from element in document.Elements() where element.Name == "array" from dict in element.Elements(XName.Get("dict")) select dict)
            {
                string title = null, imagePath = null, link = null;
                var subcontent = new List<InfoItemsViewModel>();
                foreach (var node in dict.Elements())
                {

                    var el = (XElement)node.NextNode;
                    if (el != null && node.Value == "title")
                    {

                        title = el.Value;
                    }
                    else if (el != null && node.Value == "image")
                    {

                        imagePath = el.Value + "@2x";
                    }
                    else if (el != null && (node.Value == "html" || node.Value == "url"))
                    {

                        link = el.Value;
                    }
                    else if (node.Value == "subcontent")
                    {
                        if (el != null)
                            subcontent.AddRange(from subcon in el.Elements("dict") select subcon.Element("key") into xElement where xElement != null select new InfoItemsViewModel { Title = ((XElement)xElement.NextNode).Value, Link = ((XElement)xElement.NextNode.NextNode.NextNode).Value });
                    }

                }
                InfoItems.Add(new InfoItemsViewModel { Children = subcontent, ImagePath = imagePath, Link = link, Title = title });
            }
            _info = true;

        }

        public void ProcessSchamper(object sender, DownloadStringCompletedEventArgs e)
        {
            XElement resultElements = null;
            if ((e == null && !_fromCache) || (e != null && (e.Error != null || e.Cancelled)))
            {
                _schamper = true;
                return;
            }
            if (e == null && _fromCache)
            {
                var s = LoadFromStorage("schamper", ".xml");
                if (!s.Equals(""))
                    resultElements = XElement.Parse(s);
                else return;
            }
            else if (e != null) resultElements = XElement.Parse(SaveToStorage("schamper", ".xml", e.Result));

            if (resultElements != null)
            {
                var xElement = resultElements.Element(XName.Get("channel"));
                if (xElement != null)
                    foreach (var schamperItem in xElement.Elements())
                    {
                        if (schamperItem.Name != "item") continue;
                        var dc = XNamespace.Get("http://purl.org/dc/elements/1.1/");
                        string date = null, author = null, title = null, image = null, content = null;
                        var element = schamperItem.Element(dc + "creator");
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
                            string[] inputs = { content };
                            const string pattern = @"(https?:)?//?[^''""<>]+?\.(jpg|jpeg|gif|png)";

                            var rgx = new Regex(pattern, RegexOptions.IgnoreCase);

                            foreach (var match in from input in inputs select rgx.Matches(input) into matches where matches.Count > 0 from Match match in matches select match)
                            {
                                image = match.Value;
                            }


                        }
                        if (SchamperItems != null)
                            SchamperItems.Add(new SchamperItemsViewModel { Author = author, Content = content, ImagePath = image, Title = title, Date = date });
                    }
            }
            _schamper = true;

        }

        private string SaveToStorage(string fileName, string extension, string downLoadedString)
        {
            if (_isoStore.FileExists(fileName + extension)) _isoStore.DeleteFile(fileName + extension);

            //create new file
            using (var writeFile = new StreamWriter(new IsolatedStorageFileStream(fileName + extension, FileMode.Create, FileAccess.Write, _isoStore)))
            {
                _cacheTime = DateTime.Now;
                writeFile.Write(downLoadedString);
                writeFile.Flush();
                writeFile.Close();
                SaveSettings();
            }

            return downLoadedString;
        }

        private string LoadFromStorage(string fileName, string extension)
        {
            if (!_isoStore.FileExists(fileName + extension)) return "";
            var fileStream = _isoStore.OpenFile(fileName + extension, FileMode.Open, FileAccess.Read);
            using (var reader = new StreamReader(fileStream))
            {
                return reader.ReadToEnd();
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;
        public void NotifyPropertyChanged(String propertyName)
        {
            var handler = PropertyChanged;
            if (null == handler) return;
            if (Deployment.Current.Dispatcher.CheckAccess())
                handler(this, new PropertyChangedEventArgs(propertyName));
            else
            {
                Deployment.Current.Dispatcher.BeginInvoke(() => PropertyChanged(this, new PropertyChangedEventArgs(propertyName)));
            }
        }

        public bool PreferredContains(string In)
        {
            var i = 0;
            while (i < UserPreference.PreferredAssociations.Count && UserPreference.PreferredAssociations[i].In != In)
            {
                i++;
            }
            return i < UserPreference.PreferredAssociations.Count;
        }



      
    }
}