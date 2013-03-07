using System;
using System.Globalization;
using System.Windows.Data;
using HydraWP7.Data;

namespace HydraWP7.Converters
{
    public sealed class ActivityToBooleanConverter: IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            var activity = (ActivityItemsViewModel) value;
            if (App.ViewModel.UserPreference.AccessKey == null || value == null || !App.ViewModel.HasConnection || activity.FacebookId == null ||activity.FacebookId.Equals(""))
                return false;
            if (activity.RsvpStatus != null)
                return !activity.RsvpStatus.Equals(parameter);
            return App.ViewModel.UserPreference.AccessKey != null;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
