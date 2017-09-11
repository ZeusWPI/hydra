# API's used by the Hydra app(s)

## Schamper: Artikels
Simpele RSS op: http://www.schamper.ugent.be/rss  

## UGent: Nieuws
Simpele RSS op:  https://www.ugent.be/nl/actueel/nieuws/recente_nieuwsberichten/@@rss2json  

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
TODO
