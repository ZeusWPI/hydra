using System;
using System.Globalization;
using System.Windows.Data;
using HydraWP7.Data;
using Microsoft.Phone.Controls;

namespace HydraWP7.Converters
{
    public sealed class ObjectToBooleanConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (parameter.Equals("toggleSettings"))
            {
                var isChecked = ((ToggleSwitch) value).IsChecked;
                return isChecked != null && (bool) isChecked;
            }
            if (!(value is Association))
            {
                return false;
            }
            var item = (Association) value;
            return App.ViewModel.UserPreference.PreferredAssociations.Contains(item);
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
