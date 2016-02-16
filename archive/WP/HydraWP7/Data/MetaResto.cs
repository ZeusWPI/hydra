using System.Collections.Generic;
using System.Runtime.Serialization;

namespace HydraWP7.Data
{
    [DataContract]
    public class MetaResto
    {

        [DataMember(Name = "legend")]
        public List<Legenda> Legenda { get; set; }

        [DataMember(Name = "locations")]
        public List<Location> Locations { get; set; } 
    }

    [DataContract]
    public class Location
    {
        [DataMember(Name = "name")]
        public string Name { get; set; }

        [DataMember(Name = "address")]
        public string Address { get; set; }



        /// <summary>
        /// this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns> the content of the news item</returns>
        [DataMember(Name = "latitude")]
        public double Latitude { get; set; }



        /// <summary>
        /// this property is used in the view to display its value using a Binding.
        /// </summary>
        /// <returns> the longitude of the location</returns>
        [DataMember(Name = "longitude")]
        public double Longitude { get; set; }



    }

    [DataContract]
    public class Legenda
    {
        [DataMember(Name = "key")]
        public string Key { get; set; }

        [DataMember(Name = "value")]
        public string Value { get; set; }


    }
}
