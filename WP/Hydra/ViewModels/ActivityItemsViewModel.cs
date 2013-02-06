using System;
using System.ComponentModel;
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
        //    "title": "Jobfair",
        //    "association": "VTK",
        //    "start": "2013-02-26T10:00:00Z",
        //    "end": "2013-02-26T10:00:00Z",
        //    "location": "ICC Gent",
        //    "longitude": 51.03701, "latitude": 3.72139,
        //    "description": "Op onze jaarlijkse VTK Jobfair brengen we zoveel mogelijk bedrijven die geïnteresseerd zijn om ingenieurs aan te werven, samen onder een dak.</p><p>Aan de verschillende bedrijfsstanden die het ICC vullen, kan je allerhande informatie vergaren en eerste gesprekken aanknopen. Verder zijn er ook bedrijfspresentaties en een gezellige bar. <br />Ook voor eerste masters kan dit een heel interessante dag zijn. Kom allemaal zeker eens een kijkje nemen.</p><p>De bedrijfspresentaties starten om 13u. Schrijf je onderaan deze pagina in. Na de presentatie word je getrakteerd op een broodje. De volgende bedrijven zullen dit jaar een presentatie geven: <a href=\"http://www.basf.com/group/corporate/en/\">BASF</a>",
        //    "url": "http://vtk.ugent.be/recruitment/events/2013/02/26/jobfair/",
        //    "facebook_id": "326901177416254",
        //    "categories": ["recruitment"]
        //},


        private string _location;
        /// <summary>
        /// this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns> the location of the item</returns>
        [DataMember(Name = "location")]
        public string Location
        {
            get
            {
                return _location;
            }
            set
            {
                if (value != _location)
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