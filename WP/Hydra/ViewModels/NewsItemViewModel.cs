using System;
using System.ComponentModel;
using System.Globalization;
using System.Runtime.Serialization;

namespace Hydra.ViewModels
{
    [DataContract]
    public class NewsItemViewModel : INotifyPropertyChanged
    {

        //      example given
        //[
        //    {
        //        "title": "Zeus zoekt medewerkers voor 12urenloop!",
        //        "association": "ZEUS", // for unknown clubs just use this as the display value
        //        "date": "2013-02-1T10:00:00Z",
        //        "content": "Op onze jaarlijkse VTK Jobfair brengen we zoveel mogelijk bedrijven die geÃ¯nteresseerd zijn om ingenieurs aan te werven, samen onder een dak.
        //</p><p>Aan de verschillende bedrijfsstanden die het ICC vullen, kan je allerhande informatie vergaren en eerste gesprekken aanknopen. Verder zijn er ook bedrijfspresentaties en een gezellige bar. <br />Ook voor eerste masters kan dit een heel interessante dag zijn. Kom allemaal zeker eens een kijkje nemen.
        //</p><p>De bedrijfspresentaties starten om 13u. Schrijf je onderaan deze pagina in. Na de presentatie word je getrakteerd op een broodje. De volgende bedrijven zullen dit jaar een presentatie geven: <a href=\"http://www.basf.com/group/corporate/en/\">BASF</a>", // markdown rendered as html
        //    "highlighted": true
        //    },
        //]


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

        [DataMember(Name = "title")]
        public string FullTitle { get; protected set; }


        [DataMember(Name = "association")]
        protected string _assocition;
        /// <summary>
        /// author property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns>the asociation linked to this new item</returns>
        public string Assocition
        {
            get
            {
                return _assocition;
            }
            set
            {
                if (value != _assocition)
                {
                    _assocition = value;
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
                DateTime itemDateTime = DateTime.Parse(_date);
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
}