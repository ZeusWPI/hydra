using System;
using System.Globalization;
using System.Linq;
using System.Windows;
using System.Windows.Data;
using HydraWP7.Data;

namespace HydraWP7.Converters
{
    public sealed class ObjectHeaderNewsToVisibilityConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (!(value is KeyedList<string, NewsItemViewModel>))
            {
                return Visibility.Collapsed;
            }


            var items = (KeyedList<string, NewsItemViewModel>)value;

            if (items.Any(item => (App.ViewModel.UserPreference.IsFiltering && App.ViewModel.UserPreference.PreferredAssociations.Count > 0) && (App.ViewModel.PreferredContains(item.Assocition.In) || item.IsHighLighted)))
            {
                return Visibility.Visible;
            }
            else if (!App.ViewModel.UserPreference.IsFiltering)
            {
                return Visibility.Visible;


            }


            return Visibility.Collapsed;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}