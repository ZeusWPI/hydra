using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Data;
using Hydra.Data;

namespace Hydra.Converters
{
    public sealed class ObjectToStyleConverter:IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if(!App.ViewModel.UserPreference.IsFiltering)
                return Application.Current.Resources["NormalNotHighLighted"];
            if (!(value is NewsItemViewModel))
            {
                return Application.Current.Resources["NormalNotHighLighted"];
            }
            var item = (NewsItemViewModel) value;
            if (item.IsHighLighted || App.ViewModel.PreferredContains(item.Assocition.In))
                return Application.Current.Resources["HighLighted"];
            return Application.Current.Resources["NormalNotHighLighted"];
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
