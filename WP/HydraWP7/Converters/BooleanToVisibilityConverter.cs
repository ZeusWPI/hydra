using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;

namespace HydraWP7.Converters
{
    public class BooleanToVisibilityConverter:IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            try
            {
                if (System.Convert.ToBoolean(value))
                    return !string.Equals(parameter,"closed") ? Visibility.Visible : Visibility.Collapsed;
                return Visibility.Collapsed;
            }
            catch (Exception)
            {

                return Visibility.Collapsed;
            }
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
