using System;
using System.ComponentModel;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace Hydra.ViewModels
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
                if (_title.Length > 30)
                {
                    const int i = 31;
                    if (i == _title.Length)
                        return _title.Substring(0, i);
                    return _title.Substring(0, i - 3) + "...";
                }
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

        public string FullTitle
        {
            get { return _title; }
        }
        private string _date;
        public string Date
        {
            get
            {
                return _date;
            }
            set
            {
                if (value != _date)
                {
                    _date = value;
                    NotifyPropertyChanged("date");
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
                var cul = new System.Globalization.CultureInfo("nl-BE");
                var t = DateTime.Parse(_date, cul);
                return _author + " op " + t.ToString("dd/MM/yyyy",cul);
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

       
        private ImageSource _image;

        public ImageSource Image
        {
            get
            {
                if (_image == null && _imagePath != null)
                {

                    _image = new BitmapImage(new Uri(_imagePath));
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