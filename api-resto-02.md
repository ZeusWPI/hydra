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

## Technical description

| Endpoint                              | Description                    |
|---------------------------------------|--------------------------------|
| [`GET /meta.json`](#metadata)         | Information about the resto's. |
| [`GET /sandwiches.json`](#sandwiches) | List of available sandwiches   |
| [`GET /extrafood.json`](#extra-food)  | List of additional available items, such as breakfast or desserts. |
| [`GET /menu/{endpoint}/overview.json`](#overview) | The future menu for a specific resto |
| [`GET /menu/{endpoint}/{year}/{month}/{day}.json`](#day-menu) | The menu for a particular day. |

### Metadata

**Endpoint**: `GET /meta.json`

The main entry point for the API. Provides a list of all resto location supported by the API.
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

The response is an object with one field, `locations`, a list of resto locations. Most fields in the location
self explanatory.

| Field           | Description 
|-----------------|-------------
| `name`         | Name of the resto 
| `address`      | Address of the resto
| `latitude`, `longitude` | Coordinates of the resto
| `type` | The main type of the resto. For example, `resto` indicates it is a resto, but it might also be a cafetaria.
| `endpoint` | The endpoint for this resto. Can be used in `/resto/menu/{ENDPOINT}`. See [Overview](#overview) or [Day menu](#day-menu).
| `open` | Lists the intervals in which each type is opened.

### Sandwiches

**Endpoint**: `GET /sandwhiches.json`

Lists available sandwiches, their price and their ingredients. Sample output:


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
| `price_medium` | The price in euros for a normal sandwich.
| `price_medium` | The price in euros for a small sandwich.


### Extra food

**Endpoint**: `GET /extrafood.json`

Returns additional items that are available. The availability depends on the location, but is not known. Sample output:

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

There are three lists in the response: `breakfast`, `desserts` and `drinks`. Each item in a list consists of a `name`,
and a `price` in euros.

### Overview

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
    ]
  }
]
```

The output consists of an array, with a menu object for each day. See [Day Menu](#day-menu) for a description.

### Day Menu

**Endpoint**: `GET /menu/{endpoint}/{year}/{month}/{day}.json`

**Parameters**:

- _endpoint_ — The endpoint for the resto. Available endpoint can be queried using the [Metadata](#metadata) request.
- _year_ — The year of the date. Formatted in ISO 8601 (`YYYY`).
- _month_ — The month of the date. Values must be in the interval [1-12], and formatted without zeroes (commonly indicated as `M`).
- _day_ — The day of the date. Values must be in the interval [1-31], and formatted without zeroes (commonly indicated as `D`).

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
  ]
}
```

A menu object consists of:

| Field | Description
|-------|------------
| `date` | The date of the menu. The date's format follows ISO 8601 (`YYYY-MM-DD`).
| `open` | If set to `true`, the resto is open, otherwise not. If set to `false`, none of the fields below are present.<br><br>Note that this is no guarantee: some days (like the weekends) are simply not present in the output.
| `vegetables` | A list of available vegetables.
| `meals` | A list of meal objects (see below).

A meal object consists of:

| Field | Description
|-------|------------
| `kind` | The kind of the meal. Expected values are currently `meat`, `fish`, `soup`, `vegetarian` or `vegan`. Applications must be able to handle changes to the possible values.
| `name` | The name of the meal.
| `price` | Textual representation of the price.
| `type` | The meal type. Is currently `main` of `side`, but applications must be able to handle changes to the possible values.

How an application handles changes to possible values (indicated above where this is applicable), is not specified.
The application might simply ignore new values.

