using System.Windows;
using Microsoft.Phone.Controls;

namespace Hydra
{
    public partial class Settings
    {
        public Settings()
        {
            InitializeComponent();
            DataContext = App.ViewModel;
        }


        private void ToggleSwitch_OnChecked(object sender, RoutedEventArgs e)
        {
            toggleSwitch.Content = "Aan";
        }

        private void ToggleSwitchUnChecked(object sender, RoutedEventArgs e)
        {
            toggleSwitch.Content = "Uit";
        }

        
    }
}