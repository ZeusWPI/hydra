# Resto API 2.0

## Introduction

The resto API provides information about the student restaurants of Ghent University.

This data is scraped from https://www.ugent.be/student/nl/meer-dan-studeren/resto.

In the (far) future, we might also include data from https://www.hogent.be/student/catering/weekmenu/.

The menu data is property of Ghent University. We don't guarantee the correctness or completeness of the data.

## Versioning and status

This document describes the current version of the API, version 2.0.

| Version                | Endpoint                                   | Status     |
|------------------------|--------------------------------------------|------------|
| [1.0](api-resto-01.md) | https://zeus.ugent.be/hydra/api/1.0/resto/ | deprecated |
| 2.0 (this)             | https://zeus.ugent.be/hydra/api/2.0/resto/ | current    |

## Data dump

All scraped data available in this API is also available as a [git repository](https://git.zeus.gent/hydra/data). If you need all available data, it is probably easier and faster to download or clone the repo.

## Changelog

- _April 2019_ - Added new `message` field to menu to indicate closures and changes in meals.

## Technical description

| Endpoint                              | Description                    |
|---------------------------------------|--------------------------------|
| [`GET /meta.json`](#metadata)         | Information about the restos. |
| [`GET /extrafood.json`](#extra-food)  | List of additional available items, such as breakfast or desserts. |
| [`GET /menu/{endpoint}/overview.json`](#overview-menu) | The future menu for a specific resto. |
| [`GET /menu/{endpoint}/{year}/{month}/{day}.json`](#day-menu) | The menu for a particular day. |
| `GET /sandwiches.json` | (deprecated)   |
| [`GET /sandwiches/static.json`](#regular-sandwiches)         | List of normal sandwiches. |
| [`GET /sandwiches/overview.json`](#weekly-sandwiches-overview)         | Upcoming ecological sandwiches. |
| [`GET /sandwiches/{year}.json`](#weekly-sandwiches-yearly)         | All ecological sandwiches. |

Date and hour specifiers are from ISO 8601:2014.

### Metadata

**Endpoint**: `GET /meta.json`

The main entry point for the API. Provides a list of all locations known to the API. This data is manually curated; please raise an issue if data is missing or incorrect.
Example response:

```json
{
  "locations": [
    {
      "name": "Resto Campus Sterre",
      "address": "Krijgslaan 281",
      "latitude": 51.026024,
      "longitude": 3.712939,
      "type": "resto",
      "endpoint": "nl",
      "open": {
        "resto": [
          [
            "11:15",
            "14:00"
          ]
        ],
        "cafetaria": [
          [
            "08:00",
            "14:00"
          ]
        ]
      }
    }
  ]
}
```

The response is an object with one field, `locations`, a list of locations.

| Field           | Description 
|-----------------|-------------
| `name`         | Name of the location.
| `address`      | Address of the location.
| `latitude`, `longitude` | Coordinates of the location.
| `type` | The main type of the resto. For example, `resto` indicates it is a resto, but it might also be a cafetaria.
| `endpoint` | The endpoint for this resto. Can be used in `/resto/menu/{ENDPOINT}`. See [Overview](#overview) or [Day menu](#day-menu).
| `open` | Lists the intervals in which this location is open, for each type of the location. Uses ISO 8601:2014's extended format with reduced accuracy (`hh:mm`). These are the regular opening hours; holidays and other exceptional closures are not accounted for.

### Extra food

**Endpoint**: `GET /extrafood.json`

Returns additional items that may be available. The actual availability varies per location, but this information is not known in the API. Sample output:

```json
{
  "breakfast": [
    {
      "name": "Croissant",
      "price": "0.80"
    }
  ],
  "desserts": [
    {
      "name": "Vruchtenyoghurt",
      "price": "0.70"
    }
  ],
  "drinks": [
    {
      "name": "Plat water 1l",
      "price": "1.20"
    }
  ]
}
```

There are three lists in the response: `breakfast`, `desserts` and `drinks`. Each item in a list consists of a `name` and a `price` in euros (textual).

_Note_: the price format is not identical as the price format used by the [Day Menu](#day-menu) output.

### Overview menu

**Endpoint**: `GET \menu\{endpoint}\overview.json`

**Parameters**:
- _endpoint_ -- The endpoint for the resto. Available endpoint can be queried using the [Metadata](#metadata) request.

Returns the menu for each available day in the future, including today. Sample output:
```json
[
  {
    "date": "2018-03-05",
    "meals": [
      {
        "kind": "soup",
        "name": "Minestrone",
        "price": "€ 0,50",
        "type": "side"
      },
      {
        "kind": "meat",
        "name": "Keftaballetjes in tomatensaus",
        "price": "€ 3,90",
        "type": "main"
      },
      {
        "kind": "fish",
        "name": "Alaska pollak italiano",
        "price": "€ 3,60",
        "type": "main"
      },
      {
        "kind": "vegetarian",
        "name": "Moussaka met seitan",
        "price": "€ 4,70",
        "type": "main"
      }
    ],
    "open": true,
    "vegetables": [
      "Bloemkool",
      "Prinsessengroenten"
    ],
    "message": "Alle studenten krijgen op vertoon van Hydra 150% korting."
  }
]
```

The output consists of an array, with a menu object for each day. See [Day Menu](#day-menu) for a description.

### Day Menu

**Endpoint**: `GET /menu/{endpoint}/{year}/{month}/{day}.json`

**Parameters**:

Date formatters in this section are from ISO 8601:2014. Dates are basically ISO, but without leading zeroes.

- _endpoint_ — The endpoint for the resto. Available endpoint can be queried using the [Metadata](#metadata) request.
- _year_ — The year of the date. Values must be a positive integer. Currently, the earliest available year is 2016 (but this might change in the future). ISO format: `Y̲Y`.
- _month_ — The month of the date. Values must be in the interval [1-12], and formatted without leading zeroes. ISO format: `M̲M`
- _day_ — The day of the date. Values must be in the interval [1-31], and formatted without leading zeroes. ISO format: `D̲D`.

A sample endpoint is `/menu/nl/2017/5/18.json`. Sample output is:

```json
{
  "date": "2018-03-05",
  "meals": [
    {
      "kind": "soup",
      "name": "Minestrone",
      "price": "€ 0,50",
      "type": "side"
    },
    {
      "kind": "meat",
      "name": "Keftaballetjes in tomatensaus",
      "price": "€ 3,90",
      "type": "main"
    },
    {
      "kind": "fish",
      "name": "Alaska pollak italiano",
      "price": "€ 3,60",
      "type": "main"
    },
    {
      "kind": "vegetarian",
      "name": "Moussaka met seitan",
      "price": "€ 4,70",
      "type": "main"
    }
  ],
  "open": true,
  "vegetables": [
    "Bloemkool",
    "Prinsessengroenten"
  ],
  "message": "Alle studenten krijgen op vertoon van Hydra 150% korting."
}
```

A menu object consists of:

| Field | Description
|-------|------------
| `date` | The date of the menu. The date's format follows ISO 8601:2004's extended format (`YYYY-MM-DD`).
| `open` | If set to `true`, the resto is open, otherwise not. If set to `false`. <br><br>Note that this is no guarantee: some days (like the weekends) are simply not present in the output.
| `vegetables` | A list of available vegetables.
| `meals` | A list of meal objects (see below).
| `message` | Optional field containing a message to be displayed. Used for exceptional closures or changes in the menu. For example, if `open` is `false`, the message could be an explanation for the closure.

A meal object consists of:

| Field | Description
|-------|------------
| `kind` | The kind of the meal. Expected values are currently `meat`, `fish`, `soup`, `vegetarian` or `vegan`. Applications must be able to handle changes to the possible values.
| `name` | The name of the meal.
| `price` | Textual representation of the price.
| `type` | The meal type. Is currently `main` or `side`, but applications must be able to handle changes to the possible values.

How an application handles changes to possible values (indicated above where this is applicable), is not specified.
The application might simply ignore new values.

### Regular sandwiches

**Endpoint**: `GET /sandwiches/static.json`

Lists available regular sandwiches, their price and their ingredients. Sample output:


```json
[
  {
    "ingredients": [
      "brie",
      "honing",
      "pijnboompitten",
      "sla"
    ],
    "name": "Brie",
    "price_medium": "2.40",
    "price_small": "1.50"
  }
]
```

| Field | Description
|-------|-------------
| `ingredients` | A list of the ingredients in the sandwich.
| `name` | The name of the sandwich.
| `price_medium` | The (textual) price in euros for a normal sandwich.
| `price_medium` | The (textual) price in euros for a small sandwich.

### Weekly sandwiches overview

**Endpoint**: `GET /sandwiches/overview.json`

Lists all upcoming ecological sandwiches of the week ("ecologisch broodje van de week"). Output is in the same format as [Weekly sandwiches yearly](#weekly-sandwiches-yearly).

### Weekly sandwiches yearly

**Endpoint**: `GET /sandwiches/{year}.json`

**Parameters**:
- _year_ -- Which year you want the sandwiches of. Values must be a positive integer. Currently, the earliest available year is 2019 (but this might change in the future). ISO format: `YYYY`.

Lists all sandwiches which were or are available in the specified year. Sample output:

```json
[
  {
    "start": "2019-09-16",
    "end": "2019-09-20",
    "ingredients": [
      "gebakken champignons met tofu (soja)",
      "mayonaise",
      "basilicum"
    ],
    "name": "Champignonsalade",
    "vegan": false
  }
]
```

| Field | Description
|-------|-------------
| `ingredients` | A list of the ingredients in the sandwich.
| `name` | The name of the sandwich.
| `start` | Inclusive start date on which the sandwich is available. The date's format follows ISO 8601:2004's extended format (YYYY-MM-DD).
| `end` | Inclusive start date on which the sandwich is available. The date's format follows ISO 8601:2004's extended format (YYYY-MM-DD).
| `vegan` | Boolean indicating if the sandwich is vegan or not (not to be confused with vegetarian).



