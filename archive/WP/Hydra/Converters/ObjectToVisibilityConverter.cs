using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;
using Hydra.Data;

namespace Hydra.Converters
{
    public sealed class ObjectToVisibilityConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (!App.ViewModel.UserPreference.IsFiltering)
                return Visibility.Visible;
            if (!(value is NewsItemViewModel))
            {
                return Visibility.Collapsed;
            }
            var item = (NewsItemViewModel) value;
            if ((App.ViewModel.UserPreference.IsFiltering && App.ViewModel.UserPreference.PreferredAssociations.Count > 0) && (!App.ViewModel.PreferredContains(item.Assocition.In) && !item.IsHighLighted))
                return Visibility.Collapsed;
                
            return Visibility.Visible;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }

    
}
