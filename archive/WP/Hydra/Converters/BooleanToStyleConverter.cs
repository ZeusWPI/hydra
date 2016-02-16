using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;

namespace Hydra.Converters
{
    public sealed class BooleanToStyleConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            var flag = false;
            if (value is bool)
            {
                flag = (bool)value;
            }
                return flag ? Application.Current.Resources["Recommended"] : Application.Current.Resources["Normal"];
            
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}