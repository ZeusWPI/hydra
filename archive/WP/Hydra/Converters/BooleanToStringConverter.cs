using System;
using System.Globalization;
using System.Windows.Data;

namespace Hydra.Converters
{
    public sealed class BooleanToStringConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            var flag = false;
            if (value is bool)
            {
                flag = (bool)value;
            }
            return flag ? "Uit" : "Aan" ;
            
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
