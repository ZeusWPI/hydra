using System;
using System.ComponentModel;
using System.Globalization;
using System.Runtime.Serialization;

namespace HydraWP7.Data
{
    [DataContract]
    public class NewsItemViewModel : INotifyPropertyChanged
    {

        //      example given
        //{"title":"Open repetitie GUK",
        //"content":"<p>Dinsdag 2 oktober houdt het Gents Universitair Koor haar tweede open repetitie!\nWaar? De Therminal - Trechterzaal. Hoveniersberg 24\nWanneer? 19u45-22u\nAlle ge\u00efnteresseerden welkom<\/p>\n",
        //"date":"2012-10-01T21:32:35+02:00",
        //"association":{"internal_name":"GUK","full_name":null,"display_name":"Gents Universitair Koor"},
        //"highlighted":0}


        /// <summary>
        /// title is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns></returns>
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

        //private bool _highlighted;
        [DataMember(Name = "highlighted")]
        public bool IsHighLighted
        {
            get;
            set;
        }

        [DataMember(Name = "title")]
        public string FullTitle { get; protected set; }


        private Association _association;
        /// <summary>
        /// author property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns>the asociation linked to this new item</returns>
        [DataMember(Name = "association")]
        public Association Assocition
        {
            get
            {
                return _association;
            }
            set
            {
                if (value != _association)
                {
                    _association = value;
                    NotifyPropertyChanged("association");
                }
            }
        }
        [DataMember(Name = "content")]
        protected string _content;
        /// <summary>
        /// this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns> the content of the news item</returns>
        public virtual string Content
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
        [DataMember(Name = "date")]
        protected string _date;
        /// <summary>
        /// this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns> the date of the news item</returns>
        public string Date
        {
            get
            {
                var itemDateTime = DateTime.Parse(_date);
                return itemDateTime.ToString("g", new CultureInfo("nl-BE"));
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

        public event PropertyChangedEventHandler PropertyChanged;
        protected void NotifyPropertyChanged(String propertyName)
        {
            PropertyChangedEventHandler handler = PropertyChanged;
            if (null != handler)
            {
                handler(this, new PropertyChangedEventArgs(propertyName));
            }
        }
    }

    [DataContract(Name = "association")]
    public class Association
    {
        [DataMember(Name = "internal_name")]
        public string In { get; set; }

        private string _fn;

        [DataMember(Name = "full_name")]
        public string Fn
        {
            get { return _fn ?? "Onbekend"; }
            set
            {
                _fn = value;
            }
        }
        [DataMember(Name = "display_name")]
        public string Dn { get; set; }

        public string Parent { get; set; }

        public string DnFn
        {
            get
            {
                if (Fn != null && !Fn.Equals("Onbekend"))
                    return Dn + "(" + Fn + ")";
                return Dn;
            }
        }

        public override string ToString()
        {
            return Dn;
        }
    }
}