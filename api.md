# API's used by the Hydra app(s)

## Schamper: Artikels
Simpele RSS op: http://www.schamper.ugent.be/rss  

## UGent: Nieuws
Simpele RSS op:  https://www.ugent.be/nl/actueel/nieuws/recente_nieuwsberichten/@@rss2json  

## UGent: Bibliotheken
Alle bibliotheken (JSON): http://widgets.lib.ugent.be/libraries

Agenda van specifieke bib (gebruikt het `code` attribuut van de bib als identifier):
http://widgets.lib.ugent.be/libraries/BHSL/calendar.json?pretty=1

## DSA: Nieuws, Activiteiten & Verenigingen
Complete representation of all data.
http://student.ugent.be/hydra/api  

## Zeus WPI: Resto, info & special events
Data van de resto scraper, statische info, en soms wat speciale events.
https://zeus.ugent.be/hydra/api/

Deze data wordt gescraped van https://www.ugent.be/student/nl/meer-dan-studeren/resto.  
Potentieel komt ooit deze data daar ook bij: https://www.hogent.be/student/catering/weekmenu/.

Example resto json
```
{
    'date': '2015-11-16',
    'open': true,
    'meals': [
        {
            'type': 'soup',
            'name': 'Witloofroomsoep',
            'price': 50,
            'kind': 'side'
        },
        {
            'type': 'soup'
            'name': 'Goulash soep',
            'price': 220,
            'kind': 'main'
        },
        {
            'type': 'main'
            'name': 'Toscaans kalkoenlapje',
            'price': 360,
            'kind': 'meat'
        },
        {
            'type': 'main'
            'name': 'Quiche Lorraine',
            'price': 350,
            'kind': 'meat'
        },
        {
            'type': 'main'
            'name': 'Zalmsteak gratino GLOBAL GAP',
            'price': 380,
            'kind': 'fish'
        },
        {
            'type': 'main'
            'name': 'Gierst-kaas schnitzel',
            'price': 340,
            'kind': 'vegetarian'
        }
    ]
    'vegetables': [
        'Bladspinazie',
        'Stoemp van wortel'
    ]
}
```

## UGent: Minerva
TODO

## Urgent.fm: Radio Stream
Data van de urgent scraper. Komt van http://urgent.fm/listen_live.config en http://urgent.fm.

```
{
    "name": "LISTEN UP",
    "url": "http://195.10.10.201/urgent/high.mp3?GKID=87baba5a83f011e7942300163ea2c744",
    "validUntil": "2017-10-17T01:23:25.369161"
}

```

## Desserts, drinks and breakfast
Deze data wordt gescraped van https://www.ugent.be/student/nl/meer-dan-studeren/resto. (zie resto)

```
{
    "breakfast": [
        {
            "name": "Chocoladekoek",
            "price": "0.80"
        },
        {
            "name": "Kiwi, mandarijn, clementine, meloen, watermeloen",
            "price": "0.60"
        }
    ],
    "desserts": [
        {
            "name": "Vruchtenyoghurt",
            "price": "0.70"
        },
        {
            "name": "Griekse vruchtenyoghurt",
            "price": "1.30"
        },
        {
            "name": "Chocomousse",
            "price": "1.30"
        }
    ],
    "drinks": [
        {
            "name": "Warme dranken Fair Trade",
            "price": "0.60"
        },
        {
            "name": "Rode wijn Fair Trade",
            "price": "3.00"
        },
        {
            "name": "Witte wijn Fair Trade",
            "price": "3.00"
        }
    ]
}
```
