using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Data;
using Hydra.Data;

namespace Hydra.Converters
{
    public sealed class StringToImageConverter:IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            try
            {
                var idx=System.Convert.ToInt32(parameter);
                return ((ActivityItemsViewModel) value).FriendsImage(idx);
            }catch(Exception e)
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
