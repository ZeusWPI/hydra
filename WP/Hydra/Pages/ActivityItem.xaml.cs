using System;
using System.Device.Location;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Navigation;
using Hydra.Data;
using Microsoft.Phone.Controls;
using Microsoft.Phone.Tasks;

namespace Hydra.Pages
{
    public partial class ActivityItem : PhoneApplicationPage
    {
        private ActivityItemsViewModel _item;
        public ActivityItem()
        {
            InitializeComponent();
        }

        // Load data for the ViewModel NewsItems
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            try
            {
                _item = App.ViewModel.ActivityItems.ElementAt(Convert.ToInt32(NavigationContext.QueryString["activityItem"]));
                if (_item != null)
                {
                    DataContext = _item;
                }
            }
            catch (Exception ex)
            {
                NavigationService.Navigate(new Uri("/Pages/MainPage.xaml", UriKind.Relative));
            }

        }

        private void LocationHandler(object sender, System.Windows.Input.GestureEventArgs e)
        {
            new BingMapsDirectionsTask { End = new LabeledMapLocation(_item.Location, new GeoCoordinate(_item.Latitude, _item.Longitude)) }.Show();
        }


        private void ButtonsOnClick(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            if (button != null) App.ViewModel.SetRsvp(button.Name, (ActivityItemsViewModel)DataContext);
            if (button != null && button.Name.Equals("attending"))
            {
                attending.IsEnabled = false;
                declined.IsEnabled = true;
                maybe.IsEnabled = true;
            }
            else if (button != null && button.Name.Equals("maybe"))
            {
                attending.IsEnabled = true;
                declined.IsEnabled = true;
                maybe.IsEnabled = false;
            }
            else if (button != null && button.Name.Equals("declined"))
            {
                attending.IsEnabled = true;
                declined.IsEnabled = false;
                maybe.IsEnabled = true;
            }
        }
    }
}