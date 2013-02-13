using System;
using System.Device.Location;
using System.Linq;
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

            _item = App.ViewModel.ActivityItems.ElementAt(Convert.ToInt32(NavigationContext.QueryString["activityItem"]));
            if (_item != null)
            {
                DataContext = _item;
            }
            else
            {
                //TODO:let's go back, shall we
            }

        }

        private void LocationHandler(object sender, System.Windows.Input.GestureEventArgs e)
        {
            new BingMapsDirectionsTask { End = new LabeledMapLocation(_item.Location, new GeoCoordinate(_item.Latitude, _item.Longitude)) }.Show();
           
        }

        
    }
}