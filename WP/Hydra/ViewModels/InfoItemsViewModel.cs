using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace Hydra.ViewModels
{
    public class InfoItemsViewModel : INotifyPropertyChanged
    {
        private string _title;
        /// <summary>
        /// this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns>title of the info item</returns>
        public string Title
        {
            get
            {
                return _title;
            }
            set
            {
                if (value != _title)
                {
                    _title = value;
                    NotifyPropertyChanged("title");
                }
            }
        }

        private string _link;
        public string Link
        {
            get { return _link; }
            set
            {
                if (value != null)
                {
                    if (!value.StartsWith("http"))
                    {
                        _link = "Resources/" + value;
                    }
                    else
                    {
                        _link = value;
                    }
                }
            }
        }

        public List<InfoItemsViewModel> Children
        {
            get; set;
        }

        private string _imagePath;
        /// <summary>
        ///  this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns>imagepath extracted from xml</returns>
        public string ImagePath
        {
            get
            {
                return _imagePath;
            }
            set
            {
                if (value != _imagePath)
                {
                    _imagePath = "Assets/"+value+".png";
                    NotifyPropertyChanged("imagePath");
                }
            }
        }

        /// <summary>
        /// this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns>the image itself</returns>
        private ImageSource _image;

        public ImageSource Image
        {
            get
            {
                if (_image == null && _imagePath != null)
                {

                    _image = new BitmapImage(new Uri(@_imagePath,UriKind.Relative));
                }
                return _image;
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;
        private void NotifyPropertyChanged(String propertyName)
        {
            PropertyChangedEventHandler handler = PropertyChanged;
            if (null != handler)
            {
                handler(this, new PropertyChangedEventArgs(propertyName));
            }
        }
    }
}