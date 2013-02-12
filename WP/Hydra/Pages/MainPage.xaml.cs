using System;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Navigation;
using Hydra.Data;
using Microsoft.Phone.Controls;
using Microsoft.Phone.Shell;

namespace Hydra.Pages
{
    public partial class MainPage:PhoneApplicationPage
    {
        private int _restoItem;
        // Constructor
        public MainPage()
        {
            InitializeComponent();
            _restoItem = 0;
            ApplicationBar = (ApplicationBar)Resources["DefaultAppBar"];
	      
        }

       

        // Load data for the ViewModel NewsItems
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
           
            if (App.ViewModel.IsDataLoaded) return;
            App.ViewModel.LoadData();
            DataContext = App.ViewModel;
            LoadResto();
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

        private void MainPanoramaSelectionChangedShowApplicationBar(object sender, SelectionChangedEventArgs e)
        {
            var pivotItem = e.AddedItems[0] as PivotItem;
            if (pivotItem == null) return;
            var header = pivotItem.Name;
            if (header != null && header.Equals("resto"))
            {
                LoadResto();
                ApplicationBar = (ApplicationBar)Resources["RestoAppBar"];
            }else
            {
                ApplicationBar = (ApplicationBar)Resources["DefaultAppBar"];
            }
        }

        private void BackAppBar(object sender, EventArgs e)
        {
            if (_restoItem > 0)
            {
                _restoItem--;
                LoadResto();
            }
            else
            {
                //TODO:
                //disable button when there is no entry to go to
            }
        }

        private void NextAppBar(object sender, EventArgs e)
        {
            if (_restoItem < App.ViewModel.RestoItems.Count - 1)
            {
                _restoItem++;
                LoadResto();
            }
            else
            {
                //TODO:
                //disable button when there is no entry to go to
            }
        }

        private void SettingsAppBar(object sender, EventArgs e)
        {
            NavigationService.Navigate(new Uri("/Pages/Settings.xaml", UriKind.Relative));
        }

        private void LegendAppBar(object sender, EventArgs e)
        {
            String legende = App.ViewModel.MetaRestoItem.Legenda.Aggregate<Legenda, string>(null, (current, leg) => current + (leg.Key + ": " + leg.Value + " \n "));
            MessageBox.Show(legende);
        }

        private void LocationAppBar(object sender, EventArgs e)
        {
            NavigationService.Navigate(new Uri("/Pages/RestoLocations.xaml", UriKind.Relative));
        }

        //private void Reload(object sender, EventArgs e)
        //{
        //    var panoramaItem = mainPanorama.SelectedItem as PanoramaItem;
        //    if (panoramaItem != null)
        //    {
        //        var name = panoramaItem.Name;
        //        if (name != null)
        //        {
        //            if (name.Equals("schamper"))
        //            {
        //                App.ViewModel.LoadSchamper();
        //            }
        //            else if(name.Equals("resto"))
        //            {
        //                App.ViewModel.LoadResto();
        //            }else if (name.Equals("news"))
        //            {
        //                App.ViewModel.LoadNews();
        //            }else if(name.Equals("activities"))
        //            {
        //                App.ViewModel.LoadInfo();
        //            }
        //        }
        //    }
        //}

        //private void GridClick(object sender, System.Windows.RoutedEventArgs e)
        //{
        //    var item = Convert.ToInt32(((TextBlock) sender).Name.Substring(1));
        //    mainPanorama.DefaultItem = mainPanorama.Items[item];

        //}


    }
}