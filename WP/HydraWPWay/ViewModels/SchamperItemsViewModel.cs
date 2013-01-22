using System;
using System.ComponentModel;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace HydraWPWay.ViewModels
{
    public class SchamperItemsViewModel : INotifyPropertyChanged
    {
        private string _title;
        /// <summary>
        /// title is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns></returns>
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

        private string _author;
        /// <summary>
        /// author property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns></returns>
        public string Author
        {
            get
            {
                return _author;
            }
            set
            {
                if (value != _author)
                {
                    _author = value;
                    NotifyPropertyChanged("author");
                }
            }
        }

        private string _content;
        /// <summary>
        /// Sample ViewModel property; this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns></returns>
        public string Content
        {
            get
            {
                return _content;
            }
            set
            {
                if (value != _content)
                {
                    _content = value;
                    NotifyPropertyChanged("content");
                }
            }
        }

        private string _imagePath;
        /// <summary>
        /// Sample ViewModel property; this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns></returns>
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
                    _imagePath = value;
                    NotifyPropertyChanged("imagePath");
                }
            }
        }

       
        private ImageSource _image = null;

        public ImageSource Image
        {
            get
            {
                if (this._image == null && this._imagePath != null)
                {

                    this._image = new BitmapImage(new Uri(this._imagePath));
                }
                return this._image;
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