using System;
using System.Windows.Controls;
using System.Windows.Navigation;
using Hydra.ViewModels;
using Microsoft.Phone.Controls;

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
            NavigationService.Navigate(new Uri("/SchamperItem.xaml?article="+App.ViewModel.SchamperItems.IndexOf(schamperItems.SelectedItem as SchamperItemsViewModel), UriKind.Relative));
        }
    }
}