using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;

namespace Hydra
{
    public sealed class BooleanToVisibilityConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            var flag = false;
            if (value is bool)
            {
                flag = (bool)value;
            }
            if (flag && (string)parameter != "toggle")
            {
                return Application.Current.Resources["Recommended"];
            }
            else if (!flag && (string)parameter != "toggle")
            {
                return Application.Current.Resources["Normal"];
            }else if((string)parameter=="toggle")
            {
                if (flag)
                    return "Aan";
                else
                    return "Uit";
            }else
            {
                return null;
            }
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}