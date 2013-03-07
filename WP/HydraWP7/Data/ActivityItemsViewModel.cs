using System;
using System.Collections.Generic;
using System.Globalization;
using System.Runtime.Serialization;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace HydraWP7.Data
{
    [DataContract]
    public class ActivityItemsViewModel : NewsItemViewModel
    {
        private const float Epsilon = 0.1f;

        public ActivityItemsViewModel()
        {
            FriendsPics=new List<string>();
        }

        
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

        public Visibility IsVisible
        {
            get
            {
                if (FacebookId == null || FacebookId.Equals("") || App.ViewModel.UserPreference.AccessKey==null)
                    return Visibility.Collapsed;
                return Visibility.Visible;
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

        public int Attendings { get; set; }

        public string ImageUri { get; set; }

        public BitmapImage Image{get
        {
            return ImageUri!=null ? new BitmapImage(new Uri(ImageUri,UriKind.Absolute)) : null;
        }
        }

        public int FriendsAttending { get; set; }

        public string RsvpStatus { get; set; }

        public BitmapImage FriendsImage(int i)
        {
                if(FriendsPics!= null && FriendsPics.Count>0 && FriendsPics[i]!=null)
                    return new BitmapImage(new Uri(FriendsPics[i]));
                return null;
        }

        public List<String> FriendsPics { get; set; }

         public String AttendingsText
        {
            get
            {
                if (FriendsAttending <= 0)
                    return Attendings + " gasten";
                return Attendings + " gasten, " + FriendsAttending + " vrienden";
            }
        }

        [DataMember(Name = "facebook_id")]
        public string FacebookId { get; set; }

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
                if (value == _url) return;
                _url = value;
                NotifyPropertyChanged("url");
            }
        }

        [DataMember(Name = "latitude")]
        private double _latitude;
        /// <summary>
        /// this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns> the content of the news item</returns>
        public double Latitude
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
        private double _longitude;
        /// <summary>
        /// this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns> the longitude of the location</returns>
        public double Longitude
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
                var itemDateTime = DateTime.Parse(_date);
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

        public string GetStartHour
        {
            get
            {
                if (_date == null)
                {
                    return "Onbekend";
                }
                var itemDateTime = DateTime.Parse(_date);
                return itemDateTime.ToString("HH:mm", new CultureInfo("nl-BE"));
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