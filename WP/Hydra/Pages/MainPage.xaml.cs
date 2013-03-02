using System;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Threading;
using Hydra.Data;
using Microsoft.Phone.BackgroundAudio;
using Microsoft.Phone.Controls;
using Microsoft.Phone.Shell;

namespace Hydra.Pages
{
    public partial class MainPage
    {
        private int _restoItem;
        private DispatcherTimer _trackPoller, _programPoller;
        private const string UrgentProgramApi = "http://urgent.fm/nowplaying/program.php";
        private const string UrgentTrackApi = "http://urgent.fm/nowplaying/livetrack.txt";
        private const string HighResolutionStreaming = "http://195.10.10.226/urgent/high.mp3?GKID=bf069408786e11e2a0e500163e914f68&fspref=aHR0cDovL3d3dy51cmdlbnQuZm0vbHVpc3Rlcm9ubGluZQ%3D%3D";
        private string _trackName, _programName;
        // Constructor
        public MainPage()
        {
            if (!App.ViewModel.HasConnection)
            {
                MessageBox.Show("Je hebt momenteel geen verbinding met het internet.\nSommige onderdelen van Hydra hebben internet nodig voor een correcte werking.\nHet zou daarom kunnen dat niet alles correct werkt!");

            }
            InitializeComponent();
            _restoItem = 0;
            ApplicationBar = (ApplicationBar)Resources["DefaultAppBar"];
            var dt = new DispatcherTimer { Interval = new TimeSpan(0, 1, 0, 0) };
            dt.Tick += LoadData;
            dt.Start();
            mainPivot.IsLocked = true;
            var pi = new DispatcherTimer { Interval = new TimeSpan(0, 0, 0, 0, 100) };
            pi.Tick += CheckData;
            pi.Start();


        }

        private void CheckData(object sender, EventArgs e)
        {
            var pi = SystemTray.ProgressIndicator;
            pi.IsVisible = !App.ViewModel.IsDataLoaded;
            mainPivot.IsLocked = !App.ViewModel.IsDataLoaded;
            if (!App.ViewModel.IsDataLoaded) return;
            var dt = (DispatcherTimer)sender;
            if(dt==null) return;
            dt.Stop();
            //var tileData = new StandardTileData {
            //Title = "Hydra UGent",
            //Count = App.ViewModel.ActivityItems.Count+App.ViewModel.NewsItems.Count+App.ViewModel.SchamperItems.Count,
            //BackTitle = "Er zijn " + App.ViewModel.ActivityItems.Count + App.ViewModel.NewsItems.Count + App.ViewModel.SchamperItems.Count + " items aanwezig, waaronder " + App.ViewModel.ActivityItems.Count + " activiteiten, " + App.ViewModel.NewsItems.Count + " nieuws items en " + App.ViewModel.SchamperItems.Count + " schamper artikellen."
            //};
            //ShellTile.ActiveTiles.First().Update(tileData);
        }

        private void LoadData(object sender, EventArgs e)
        {
            var reload = sender is DispatcherTimer;
            App.ViewModel.LoadData(reload);
            DataContext = App.ViewModel;
            App.ViewModel.NotifyPropertyChanged("items");
            LoadResto();
        }


        // Load data for the ViewModel NewsItems
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            LoadData(this, null);
            if (App.ViewModel.IsDataLoaded)
            {
                LoadResto();
            }
            if (!BackgroundAudioPlayer.Instance.PlayerState.Equals(PlayState.Playing) ||
                !BackgroundAudioPlayer.Instance.Track.Source.ToString().Contains("http://195.10.10.226/urgent/high.mp3")) return;
            PollForProgramChange(null, null);
            PollForTrackChange(null, null);
            Play.Visibility = Visibility.Collapsed;
            Pause.Visibility = Visibility.Visible;

        }

        private void LoadResto()
        {
            resto.DataContext = _restoItem < App.ViewModel.RestoItems.Count ? App.ViewModel.RestoItems[_restoItem].Day : new Day();
        }


        private void SchamperItemTapped(object sender, SelectionChangedEventArgs e)
        {
            if (e.AddedItems[0] == null) return;
            var schamperitem = e.AddedItems[0] as SchamperItemsViewModel;
            if (schamperitem != null)
                NavigationService.Navigate(new Uri("/Pages/SchamperItem.xaml?article=" + App.ViewModel.SchamperItems.IndexOf(schamperitem), UriKind.Relative));

            schamperLLS.SelectedItem = null;
        }

        private void NewsItemTapped(object sender, SelectionChangedEventArgs e)
        {
            if (e.AddedItems[0] == null) return;
            var newsItem = e.AddedItems[0] as NewsItemViewModel;
            if (newsItem != null)
                NavigationService.Navigate(new Uri("/Pages/NewsItem.xaml?newsItem=" + App.ViewModel.NewsItems.IndexOf(newsItem), UriKind.Relative));

            newsLLS.SelectedItem = null;
        }

        private void ActivityItemTapped(object sender, SelectionChangedEventArgs e)
        {
            if (e.AddedItems[0] == null) return;
            var activityItem = e.AddedItems[0] as ActivityItemsViewModel;
            if (activityItem != null)
                NavigationService.Navigate(new Uri("/Pages/ActivityItem.xaml?activityItem=" + App.ViewModel.ActivityItems.IndexOf(activityItem), UriKind.Relative));
            activityLLS.SelectedItem = null;
        }

        private void InfoItemTapped(object sender, SelectionChangedEventArgs e)
        {
            if (e.AddedItems[0] == null) return;
            var infoItem = e.AddedItems[0] as InfoItemsViewModel;
            Uri uri = null;
            var idx = App.ViewModel.InfoItems.IndexOf(infoItem);
            if (infoItem != null && infoItem.Children.Count == 0 && infoItem.Link.StartsWith("http"))
            {
                uri = new Uri(infoItem.Link, UriKind.RelativeOrAbsolute);
            }
            else if (infoItem != null && infoItem.Children.Count == 0 && !infoItem.Link.StartsWith("http"))
            {
                uri = new Uri("/Pages/InfoItemBrowser.xaml?item=" + idx, UriKind.Relative);


            }
            else if (infoItem != null && infoItem.Children.Count != 0)
            {
                uri = new Uri("/Pages/InfoItemSubcontent.xaml?item=" + idx, UriKind.Relative);

            }
            if (uri != null && uri.ToString().StartsWith("http"))
            {
                InfoItemBrowser.BrowseToUrl(infoItem.Link);
            }
            else
            {
                NavigationService.Navigate(uri);
            }

            infoLLS.SelectedItem = null;
        }

        private void MainPivotSelectionChangedShowApplicationBar(object sender, SelectionChangedEventArgs e)
        {
            var pivotItem = e.AddedItems[0] as PivotItem;
            if (pivotItem == null) return;
            var header = pivotItem.Name;
            if (header != null && header.Equals("resto"))
            {
                LoadResto();
                ApplicationBar = (ApplicationBar)Resources["RestoAppBar"];
                EnableButtons();
            }
            else
            {
                ApplicationBar = (ApplicationBar)Resources["DefaultAppBar"];
            }
        }

        private void EnableButtons()
        {
            ((ApplicationBarIconButton)ApplicationBar.Buttons[0]).IsEnabled = _restoItem > 0;
            ((ApplicationBarIconButton)ApplicationBar.Buttons[2]).IsEnabled = _restoItem + 1 <= App.ViewModel.RestoItems.Count - 1;
        }

        private void BackAppBar(object sender, EventArgs e)
        {
            if (_restoItem > 0)
            {
                _restoItem--;

                LoadResto();
            }
            EnableButtons();
        }

        private void NextAppBar(object sender, EventArgs e)
        {
            if (_restoItem < App.ViewModel.RestoItems.Count - 1)
            {
                _restoItem++;

                LoadResto();
            }
            EnableButtons();

        }

        private void SettingsAppBar(object sender, EventArgs e)
        {
            NavigationService.Navigate(new Uri("/Pages/Settings.xaml", UriKind.Relative));
        }

        private void LegendAppBar(object sender, EventArgs e)
        {
            var legende = App.ViewModel.MetaRestoItem.Legenda.Aggregate<Legenda, string>(null, (current, leg) => current + (leg.Key + ": " + leg.Value + " \n "));
            MessageBox.Show(legende);
        }

        private void LocationAppBar(object sender, EventArgs e)
        {
            NavigationService.Navigate(new Uri("/Pages/RestoLocations.xaml", UriKind.Relative));
        }

        private void PlayButton(object sender, EventArgs e)
        {
            if (!App.ViewModel.HasConnection)
            {
                return;
            }

            var audioTrack = new AudioTrack(
                    new Uri(HighResolutionStreaming, UriKind.Absolute),
                    "Geen plaat(info)",
                    "Urgent.fm",
                    null,
                    new Uri("../Assets/urgent-nowplaying@2x.jpg", UriKind.Relative),
                    null,
                    EnabledPlayerControls.Pause);
            BackgroundAudioPlayer.Instance.Track = audioTrack;
            Play.Visibility = Visibility.Collapsed;
            Pause.Visibility = Visibility.Visible;
            StartPolling(true);
            PollForProgramChange(null, null);
            PollForTrackChange(null, null);
        }

        private void StartPolling(bool start)
        {
            if (start)
            {

                if (_programPoller == null)
                {
                    _programPoller = new DispatcherTimer { Interval = new TimeSpan(0, 0, 30, 0) };
                    _programPoller.Tick += PollForProgramChange;
                }
                _programPoller.Start();
                if (_trackPoller == null)
                {
                    _trackPoller = new DispatcherTimer { Interval = new TimeSpan(0, 0, 0, 30) };
                    _trackPoller.Tick += PollForTrackChange;
                }
                _trackPoller.Start();

            }
            else
            {
                if (_trackPoller != null)
                {
                    _trackPoller.Stop();
                }
                if (_programPoller != null)
                {
                    _programPoller.Stop();
                }
            }
        }

        private void PollForTrackChange(object sender, EventArgs e)
        {
            var fetch = new WebClient();
            fetch.DownloadStringCompleted += ProcessTrack;
            fetch.DownloadStringAsync(new Uri(UrgentTrackApi));
        }

        private void PollForProgramChange(object sender, EventArgs e)
        {
            var fetch = new WebClient();
            fetch.DownloadStringCompleted += ProcessProgram;
            fetch.DownloadStringAsync(new Uri(UrgentProgramApi));
        }

        private void ProcessProgram(object sender, DownloadStringCompletedEventArgs e)
        {
            if (e != null && (e.Error != null || e.Cancelled)) return;
            if (e == null) return;
            if (_programName == null) _programName = e.Result;
            else if (_programName.Equals(e.Result) && NowPlayingProgram.Text != "") return;
            else _programName = e.Result;
            NowPlayingProgram.Text = "U luistert naar " + _programName;
            var trackInstance = BackgroundAudioPlayer.Instance.Track;
            trackInstance.BeginEdit();
            trackInstance.Album = _programName;
            trackInstance.EndEdit();
        }

        private void ProcessTrack(object sender, DownloadStringCompletedEventArgs e)
        {
            if (e != null && (e.Error != null || e.Cancelled)) return;
            if (e == null) return;
            if (_trackName == null) _trackName = e.Result;
            else if (_trackName.Equals(e.Result) && NowPlayingTrack.Text != "") return;
            else _trackName = e.Result;
            if (_trackName.Equals("Geen plaat(info)"))
            {
                if (_programName != null) _trackName = _programName;

            }
            var trackInstance = BackgroundAudioPlayer.Instance.Track;
            trackInstance.BeginEdit();
            if (_trackName.Contains("-"))
            {
                trackInstance.Artist = _trackName.Substring(0, _trackName.IndexOf("-", StringComparison.Ordinal));
                trackInstance.Title = _trackName.Substring(_trackName.IndexOf("-", StringComparison.Ordinal) + 1);
            }
            else
            {
                trackInstance.Title = _trackName;
            }
            trackInstance.EndEdit();
            if (_trackName.Equals("Geen plaat(info)") || _trackName.Equals(_programName)) return;
            NowPlayingTrack.Text = @"Speelt nu: 
            " + _trackName;
        }

        private void StopButton(object sender, EventArgs e)
        {
            if (!(BackgroundAudioPlayer.Instance.PlayerState.Equals(PlayState.Playing) || BackgroundAudioPlayer.Instance.PlayerState.Equals(PlayState.BufferingStarted) || BackgroundAudioPlayer.Instance.PlayerState.Equals(PlayState.Paused))) return;
            StartPolling(false);
            BackgroundAudioPlayer.Instance.Stop();
            Play.Visibility = Visibility.Visible;
            Pause.Visibility = Visibility.Collapsed;
            NowPlayingTrack.Text = null;
            NowPlayingProgram.Text = null;

        }

    }
}