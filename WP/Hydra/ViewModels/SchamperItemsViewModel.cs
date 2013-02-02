using System;
using System.ComponentModel;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace Hydra.ViewModels
{
    public class SchamperItemsViewModel : INotifyPropertyChanged
    {
        /// <summary>
        /// title is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns>returns title and if needed truncates manually</returns>
        public string Title
        {
            get
            {
                if (FullTitle.Length > 30)
                {
                    const int i = 31;
                    if (i == FullTitle.Length)
                        return FullTitle.Substring(0, i);
                    return FullTitle.Substring(0, i - 3) + "...";
                }
                return FullTitle;
            }
            set
            {
                if (value != FullTitle)
                {
                    FullTitle = value;
                    NotifyPropertyChanged("title");
                }
            }
        }

        public string FullTitle { get; private set; }

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
        /// <returns>The authors name and date of publshing</returns>
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
        ///  this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns>summary/content of the article extracted from xml</returns>
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