using System;
using System.Windows.Controls;
using System.Windows.Navigation;
using Hydra.ViewModels;
using Microsoft.Phone.Controls;
using Microsoft.Phone.Shell;

namespace Hydra
{
    public partial class MainPage : PhoneApplicationPage
    {
        // Constructor
        public MainPage()
        {
            InitializeComponent();

            // Set the data context of the listbox control to the sample data
            DataContext = App.ViewModel;
        }

        // Load data for the ViewModel NewsItems
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            if (!App.ViewModel.IsDataLoaded)
            {
                App.ViewModel.LoadData();
            }
        }
        


        private void SchamperItemTapped(object sender, SelectionChangedEventArgs e)
        {
            var schamperitem = e.AddedItems[0] as SchamperItemsViewModel;
            if (schamperitem != null)
                NavigationService.Navigate(new Uri("/SchamperItem.xaml?article="+App.ViewModel.SchamperItems.IndexOf(schamperitem), UriKind.Relative));
        }

        private void InfoItemTapped(object sender, SelectionChangedEventArgs e)
        {
            var infoItem=e.AddedItems[0] as InfoItemsViewModel;
            Uri uri = null; 
            var idx = App.ViewModel.InfoItems.IndexOf(infoItem);
            if(infoItem != null && infoItem.Children.Count==0 && infoItem.Link.StartsWith("http"))
            {
                uri=new Uri(infoItem.Link,UriKind.RelativeOrAbsolute);     
            }
            else if (infoItem != null && infoItem.Children.Count == 0 && !infoItem.Link.StartsWith("http"))
            {
                uri = new Uri("/InfoItemBrowser.xaml?item=" + idx, UriKind.Relative);
                

            }
            else if (infoItem != null && infoItem.Children.Count != 0)
            {
                uri = new Uri("/InfoItemSubcontent.xaml?item=" + idx, UriKind.Relative);
                
            }
            if(uri != null && uri.ToString().StartsWith("http"))
            {
                InfoItemBrowser.BrowseToUrl(infoItem.Link);
            }else
            {
                NavigationService.Navigate(uri);
            }
             
        }

        private void MainPanoramaSelectionChangedShowApplicationBar(object sender, SelectionChangedEventArgs e)
        {
            var panoramaItem = e.AddedItems[0] as PanoramaItem;
            if (panoramaItem == null) return;
            var header = (string) panoramaItem.Name;
            if(header!=null && (header.Equals("schamper") || header.Equals("resto")))
            {
                appbar.ApplicationBar.IsVisible = true;
            }
            else
            {
                appbar.ApplicationBar.IsVisible = false;
            }
        }

        private void Reload(object sender, EventArgs e)
        {
            var panoramaItem = mainPanorama.SelectedItem as PanoramaItem;
            if (panoramaItem != null)
            {
                var name = panoramaItem.Name;
                if (name != null)
                {
                    if (name.Equals("schamper"))
                    {
                        App.ViewModel.LoadSchamper();
                    }
                    else
                    {
                        App.ViewModel.LoadResto();
                    }
                }
                var toast = new ShellToast();
                toast.Title = "Synchroniseren voltooid!";
                toast.Show();

            }
        }

        
    }
}