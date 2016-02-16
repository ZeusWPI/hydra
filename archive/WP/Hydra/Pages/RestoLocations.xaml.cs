using System.Device.Location;
using System.Windows.Controls;
using Hydra.Data;
using Microsoft.Phone.Controls;
using Microsoft.Phone.Tasks;

namespace Hydra.Pages
{
    public partial class RestoLocations : PhoneApplicationPage
    {
        public RestoLocations()
        {
            DataContext = App.ViewModel.MetaRestoItem;
            InitializeComponent();
        }

        private void RestoLocationTapped(object sender, SelectionChangedEventArgs e)
        {
            var item = e.AddedItems[0] as Location;
            if(item==null)return;
            new BingMapsDirectionsTask { End = new LabeledMapLocation(item.Name, new GeoCoordinate(item.Latitude,item.Longitude)) }.Show();
            restoLLLS.SelectedItem = null;
        }
    }
}