using System;
using System.Linq;
using System.Windows.Controls;
using System.Windows.Navigation;
using HydraWP7.Data;

namespace HydraWP7.Pages
{
    public partial class InfoItemSubcontent
    {
        private InfoItemsViewModel _item;
        public InfoItemSubcontent()
        {
            InitializeComponent();
        }

        // Load data for the info item
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            _item = App.ViewModel.InfoItems.ElementAt(Convert.ToInt32(NavigationContext.QueryString["item"]));
            if (_item != null)
            {
                title.Text = _item.Title;
                list.ItemsSource = _item.Children;
            }
        }

        private void ItemSelected(object sender, SelectionChangedEventArgs e)
        {
            var selected = e.AddedItems[0] as InfoItemsViewModel;
            if (selected == null) return;
            if (selected.Link.StartsWith("http"))
            {
                InfoItemBrowser.BrowseToUrl(selected.Link);
            }
            else
            {

                var uri = new Uri("/Pages/InfoItemBrowser.xaml?item=" + App.ViewModel.InfoItems.IndexOf(_item) + "&child=" + _item.Children.IndexOf(selected), UriKind.Relative);
                NavigationService.Navigate(uri);
            }
        }
    }
}