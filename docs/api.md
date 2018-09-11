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

### Resto

Bevat alles wat met de resto's the maken heeft: metadata, menu's, drank, desserts, enz.

Deze data wordt gescraped van https://www.ugent.be/student/nl/meer-dan-studeren/resto.  
Potentieel komt ooit deze data daar ook bij: https://www.hogent.be/student/catering/weekmenu/.

Bekijk de API-documentatie van versie [2.0](apis/api-resto-02.md) of versie [1.0](apis/api-resto-01.md).

## UGent: Minerva

Bekijk de publieke API-documentatie op https://icto.ugent.be/en/content/minerva-api-v2.

## Urgent.fm: Radio Stream
Data van de urgent scraper. Komt van http://urgent.fm/listen_live.config en http://urgent.fm.

```json
{
    "name": "LISTEN UP",
    "url": "http://195.10.10.201/urgent/high.mp3?GKID=87baba5a83f011e7942300163ea2c744",
    "validUntil": "2017-10-17T01:23:25.369161"
}
```
