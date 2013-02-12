using System.Collections.Generic;
using System.Globalization;
using System.Windows;
using Hydra.Data;

namespace Hydra.Pages
{
    public partial class Settings
    {
        public Settings()
        {
            InitializeComponent();
            DataContext = App.ViewModel;
            List<AssociationList<Association>> dataSource = AssociationList<Association>.CreateGroups(App.ViewModel.Associtions,new CultureInfo("nl-BE"),s => s.Dn, true);
            associations.ItemsSource = dataSource;
        }


        protected override void OnNavigatingFrom(System.Windows.Navigation.NavigatingCancelEventArgs e)
        {
           App.ViewModel.SaveSettings();
           base.OnNavigatingFrom(e);
        }

        private void ToggleSwitch_OnChecked(object sender, RoutedEventArgs e)
        {
            toggleSwitch.Content = "Aan";
            App.ViewModel.IsChecked = true;
        }

        private void ToggleSwitchUnChecked(object sender, RoutedEventArgs e)
        {
            toggleSwitch.Content = "Uit";
            App.ViewModel.IsChecked = false;
        }

        
        private void AssociationAdded(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
        {
            var item = e.AddedItems[0] as Association;
            if(item!=null && !App.ViewModel.PreferredAssociations.Contains(item))
                App.ViewModel.PreferredAssociations.Add(item);
            else if(item!=null && App.ViewModel.PreferredAssociations.Contains(item))
            {
                App.ViewModel.PreferredAssociations.Remove(item);
            }
        }


        
    }
}