# API's used by the Hydra app(s)

## Schamper: Articles
Simple RSS at: http://www.schamper.ugent.be/rss
Wrapper available in the Zeus API.

## UGent: News
We run an ATOM to JSON converter every day.
ATOM at https://www.ugent.be/nl/actueel/overzicht/atom.xml (Dutch)

## UGent: Libraries
All libraries (JSON): http://widgets.lib.ugent.be/libraries

Calendar of a spcific library (use the `code` attribute of the library as identifier):
http://widgets.lib.ugent.be/libraries/BHSL/calendar.json?pretty=1

## DSA: Activities & Associations
https://dsa.ugent.be/swagger or, if no UGent account, https://dsa.ugent.be/api/spec

## Zeus WPI: Resto, info & special events
Data of the resto scraper, static information, and special events.
https://zeus.ugent.be/hydra/api/

Note that the association logo API is deprecated and nog longer receives updated (https://hydra.ugent.be/api/2.0/association/logo/).
Use the official one from DSA instead.

### Resto

Contains everything related to resto's.

Data is parsed from https://www.ugent.be/student/nl/meer-dan-studeren/resto.  
Maybe this data will be included some day: https://www.hogent.be/student/catering/weekmenu/.

View the API documentation at [2.0](api-resto-02.md) (or deprecated version at [1.0](api-resto-01.md)).

## Urgent.fm: Radio Stream
Data of the urgent scraper. Scraped from http://urgent.fm/listen_live.config en http://urgent.fm.

```json
{
    "name": "LISTEN UP",
    "url": "http://195.10.10.201/urgent/high.mp3?GKID=87baba5a83f011e7942300163ea2c744",
    "validUntil": "2017-10-17T01:23:25.369161"
}
```
