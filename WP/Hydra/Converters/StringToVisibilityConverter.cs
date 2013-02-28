using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;

namespace Hydra.Converters
{
    public class StringToVisibilityConverter:IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if(string.Equals(parameter,"browser"))
            {
                return App.ViewModel.UserPreference.AccessKey == null ? Visibility.Visible : Visibility.Collapsed;
            }
            return App.ViewModel.UserPreference.AccessKey == null ? Visibility.Collapsed : Visibility.Visible;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
