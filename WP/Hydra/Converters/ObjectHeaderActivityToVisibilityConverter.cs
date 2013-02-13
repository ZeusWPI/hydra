using System;
using System.Globalization;
using System.Linq;
using System.Windows;
using System.Windows.Data;
using Hydra.Data;

namespace Hydra.Converters
{
    public sealed class ObjectHeaderActivityToVisibilityConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if ( !(value is KeyedList<string, ActivityItemsViewModel>))
            {
                return Visibility.Collapsed;
            }


            var items = (KeyedList<string, ActivityItemsViewModel>)value;

            if (items.Any(item => (App.ViewModel.IsChecked && App.ViewModel.PreferredAssociations.Count > 0) && (App.ViewModel.PreferredContains(item.Assocition.In) || item.IsHighLighted)))
            {
                return Visibility.Visible;
            }
            else if (!App.ViewModel.IsChecked)
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