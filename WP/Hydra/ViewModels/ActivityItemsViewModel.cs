using System;
using System.Globalization;
using System.Runtime.Serialization;

namespace Hydra.ViewModels
{
    [DataContract]
    public class ActivityItemsViewModel : NewsItemViewModel
    {
        private const float Epsilon = 0.1f;


        // example given 
        //{
        //{"title":"Skireis",
        //"start":"2013-02-07T00:01:00+01:00",
        //"end":"2013-02-07T00:00:00+01:00",
        //"location":"Les Menuires, Les Trois Vall\u00e9es, Frankrijk",
        //"description":null,
        //"url":null,"facebook_id":null,
        //"categories":null,"highlighted":0,
        //"association":{"internal_name":"SKCENTRAAL","full_name":null,"display_name":"Senioren Konvent"}}
        //},


        private string _location;
        /// <summary>
        /// this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns> the location of the item</returns>
        [DataMember(Name = "location")]
        public string Location
        {
            get {
                return _location ?? "Onbekend";
            }
            set
            {
                if (value != _location && value!="null")
                {
                    _location = value;
                    NotifyPropertyChanged("location");
                }
            }
        }

        /// <summary>
        /// this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns> the description of the item</returns>
        [DataMember(Name = "description")]
        public new string Content
        {
            get {
                return _content ?? "Onbekend";
            }
            set
            {
                if (value == _content || value == null) return;
                _content = value;
                NotifyPropertyChanged("content");
            }
        }

        private Uri _url;
        /// <summary>
        /// this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns> the url of the item</returns>
        [DataMember(Name = "url")]
        public Uri Url
        {
            get
            {
                return _url;
            }
            set
            {
                if (value != _url)
                {
                    _url = value;
                    NotifyPropertyChanged("url");
                }
            }
        }

        [DataMember(Name = "latitude")]
        private float _latitude;
        /// <summary>
        /// this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns> the content of the news item</returns>
        public float Latitude
        {
            get
            {
                return _latitude;
            }
            set
            {
                if (Math.Abs(value - _latitude) > Epsilon)
                {
                    _latitude = value;
                    NotifyPropertyChanged("latitude");
                }
            }
        }

        [DataMember(Name = "longitude")]
        private float _longitude;
        /// <summary>
        /// this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns> the longitude of the location</returns>
        public float Longitude
        {
            get
            {
                return _longitude;
            }
            set
            {
                if (Math.Abs(value - _longitude) > Epsilon)
                {
                    _longitude = value;
                    NotifyPropertyChanged("longitude");
                }
            }
        }

        /// <summary>
        /// this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns> the start time of the item</returns>
        [DataMember(Name = "start")]
        public string StartDate
        {
            get
            {
                if (_date == null)
                {
                    return "Onbekend";
                }
                DateTime itemDateTime = DateTime.Parse(_date);
                return itemDateTime.ToString("g", new CultureInfo("nl-BE"));
            }
            set
            {
                if (value != _date)
                {
                    _date = value;
                    NotifyPropertyChanged("startDate");
                }
            }
        }

        [DataMember(Name = "end")]
        private string _endDate;
        /// <summary>
        /// this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns> the end time of the item</returns>
        public string EndDate
        {
            get
            {
                if(_endDate==null)
                {
                    return "Onbekend";
                }
                DateTime itemDateTime = DateTime.Parse(_endDate);
                return itemDateTime.ToString("g", new CultureInfo("nl-BE"));
            }
            set
            {
                if (value != _endDate)
                {
                    _endDate = value;
                    NotifyPropertyChanged("endDate");
                }
            }
        }

    }
}