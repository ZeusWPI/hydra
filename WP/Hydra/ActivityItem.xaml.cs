using System;
using System.Device.Location;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Windows.Navigation;
using Hydra.ViewModels;
using Microsoft.Phone.Controls;
using Microsoft.Phone.Tasks;

namespace Hydra
{
    public partial class ActivityItem : PhoneApplicationPage
    {
        private const string Header = "<html><head><link rel='stylesheet' type='text/css' href='../Resources/webview.css'></head><body>";
        private ActivityItemsViewModel _item;
        public ActivityItem()
        {
            InitializeComponent();
        }

        // Load data for the ViewModel NewsItems
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {

            _item = App.ViewModel.ActivityItems.ElementAt(Convert.ToInt32(NavigationContext.QueryString["activityItem"]));
            if (_item != null)
            {
                DataContext = _item;
                
                browser.NavigateToString(Header + _item.Content + "</body></html>");
            }
            else
            {
                //TODO:let's go back, shall we
            }

        }

        private void LocationHandler(object sender, System.Windows.Input.GestureEventArgs e)
        {
            new BingMapsDirectionsTask { End = new LabeledMapLocation(_item.Location, new GeoCoordinate(_item.Longitude, _item.Latitude)) }.Show();
           
        }

        
    }
}