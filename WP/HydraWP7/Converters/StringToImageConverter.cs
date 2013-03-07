using System;
using System.Globalization;
using System.Windows.Data;
using HydraWP7.Data;

namespace HydraWP7.Converters
{
    public sealed class StringToImageConverter:IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            try
            {
                var idx=System.Convert.ToInt32(parameter);
                return ((ActivityItemsViewModel) value).FriendsImage(idx);
            }catch(Exception)
            {
                //Not a valid index
                return null;
            }
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
