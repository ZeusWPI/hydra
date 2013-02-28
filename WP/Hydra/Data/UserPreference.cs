using System;
using System.Collections.ObjectModel;
using System.Windows.Media.Imaging;

namespace Hydra.Data
{
    public class UserPreference
    {

        public UserPreference()
        {

            PreferredAssociations = new ObservableCollection<Association>();
        }

        public bool IsFiltering { get; set; }

        public string FbUserId { get; set; }

        public BitmapImage UserImage
        {
            get
            {
                if(FbUserId!=null && AccessKey!= null)
                    return new BitmapImage(new Uri(string.Format("https://graph.facebook.com/{0}/picture?type={1}&access_token={2}", FbUserId, "normal", AccessKey)));
                return null;
            }
        }

        public string Name { get; set; }

        public ObservableCollection<Association> PreferredAssociations { get; set; }


        public String AccessKey { get; set; }
    }
}
