﻿using System;
using System.Collections.Generic;
using System.Globalization;
using System.Runtime.Serialization;

namespace Hydra.Data
{
    [DataContract]
    public class RestoItemsViewModel
    {


        //    "2013-02-18": {
        //    "meat": [
        //        {
        //            "name": "Mixed grill brochette*", 
        //            "price": "\u20ac 4,20", 
        //            "recommended": false
        //        }, 
        //        {
        //            "name": "Viscubes vissaus", 
        //            "price": "\u20ac 3,50", 
        //            "recommended": false
        //        }, 
        //        {
        //            "name": "Broodvlees#", 
        //            "price": "\u20ac 3,50", 
        //            "recommended": false
        //        }, 
        //        {
        //            "name": "Veg. Italiaanse veggie toast", 
        //            "price": "\u20ac 3,70", 
        //            "recommended": false
        //        }
        //    ], 
        //    "open": true, 
        //    "soup": {
        //        "name": "Wortelsoep", 
        //        "price": "\u20ac 0,50"
        //    }, 
        //    "vegetables": [
        //        "Ratatouillegroenten", 
        //        "Kriekjes"
        //    ]
        //}, 

        public Day Day { get; set; }
    }

    public class Day
    {
        private static readonly string[] Months = new[] { "januari", "februari", "maart", "april", "mei", "juni", "juli", "augustus", "september", "november", "oktober", "december" };
        private static string[] Days = new[] { "maandag","dinsdag","woensdag","donderdag","vrijdag","zaterdag","zondag"};
        private List<Dish> _dishes;
        public List<Dish> Dishes
        {
            get
            {
                if (_dishes != null)
                {
                    return _dishes;
                }
                else
                {
                    var li = new List<Dish> { new Dish(), new Dish(), new Dish(), new Dish() };
                    return li;
                }
            }
            set { if (value != _dishes) _dishes = value; }
        }

        public bool IsOpen { get; set; }

        private string _date;
        public string Date
        {
            get
            {
                if (_date == null)
                {
                    return "Laden...";
                }
                else
                {
                    var date = DateTime.Parse(_date, new CultureInfo("nl-BE")).Date;
                    if (date.Equals(DateTime.Now.Date))
                        return "Vandaag";
                    if (date.Equals(DateTime.Now.AddDays(1).Date))
                        return "Morgen";
                    if (date.Equals(DateTime.Now.AddDays(2).Date))
                        return "Overmorgen";
                    return Days[(int) date.DayOfWeek-1] + " " + date.Day + " " + Months[date.Month - 1];
                }
            }
            set
            {
                if (!Equals(value, _date))
                {
                    _date = value;
                }
            }
        }

        public bool Open { get; set; }

        private List<String> _soup;
        public List<string> Soup
        {
            get
            {
                if (_soup != null)
                    return _soup;
                else
                {
                    var li = new List<string> { "Laden...", "Laden...", "Laden...", "Laden..." };
                    return li;
                }
            }
            set
            {
                if (value != null && value != _soup)
                    _soup = value;
            }
        }

        private List<String> _vegetables;
        public List<string> Vegetables
        {
            get
            {
                if (_vegetables != null)
                    return _vegetables;
                else
                {
                    var li = new List<string> { "Laden...", "Laden..." ,"Laden..."};
                    return li;
                }
            }
            set
            {
                if (value != null && value != _vegetables)
                    _vegetables = value;
            }
        }



    }

    public class Dish
    {
        private string _name;
        public string Name { get { return _name ?? "Laden..."; } set { if (value != _name) _name = value; } }

        private string _price;
        public string Price { get { return _price ?? "Laden..."; } set { if (value != _price) _price = value; } }

        public bool IsRecommended { get; set; }
    }
}