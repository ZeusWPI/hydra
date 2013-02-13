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
            if (!(value is NewsItemViewModel))
            {
                return Visibility.Collapsed;
            }
            else
            {
                var item = (NewsItemViewModel) value;
                if((App.ViewModel.IsChecked && App.ViewModel.PreferredAssociations.Count>0) && (!App.ViewModel.PreferredContains(item.Assocition.In)&&!item.IsHighLighted))
                     return Visibility.Collapsed;
                
                return Visibility.Visible;
            }
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
