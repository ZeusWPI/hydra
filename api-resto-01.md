# Resto API 1.0

## Introduction

The resto API provides information about the student restaurants of Ghent University. 

This data is scraped from https://www.ugent.be/student/nl/meer-dan-studeren/resto.

The menu data is property of Ghent University. We don't guarantee the correctness or completeness of the data.

## Versioning and status

This document describes version 1.0 of the API.

| Version                | Endpoint                                   | Status     |
|------------------------|--------------------------------------------|------------|
| 1.0 (this)             | https://zeus.ugent.be/hydra/api/1.0/resto/ | deprecated |
| [2.0](api-resto-02.md) | https://zeus.ugent.be/hydra/api/2.0/resto/ | current    |

This API is deprecated. Applications are encouraged to migrate to version 2.0 of the API.

This means that although there are currently no concrete plans to retire the API, the API is no longer developed. New features will not be added and bugs may not be fixed.

## Data dump

All scraped data available in this API is also available as a [git repository](https://git.zeus.gent/hydra/data). If you need all available data, it is probably easier and faster to download or clone the repo.

If or when this version of the API is sunset, the data will remain available in the repo above.

## Technical description

* **`meta.json`**

  Some additional information on the restos such as the legend used and a list of their locations. For each resto a dictionary with 4 values is provided: the `name`, `address`, `latitude` and `longitude`.
  
  This information is no longer actively maintained.

* **`menu/[0-9]{4}/[O-9]{2}.json`**

  This resource contains the menus for a whole week. The first number in the URL is the year, the second one is the week number. The list will at most contain 5 entries, one for each day of the week. Each of those entries contains 1 or 4 keys.

  If the `open` key is false, all restos are closed that day and no other keys are provided. If `open` is true, the keys `meat`, `soup` and `vegetables` are also provided.

  An example structure is provided below. This is a typical structure with 4 meat entries, 1 soup entry and 2 vegetable entries.
  ```json
  {
  "2011-03-21": {
    "open": true,
    "meat": [
      {
        "name": "Kalkoengebraad",
        "price": "\u20ac 2,80",
        "recommended": true
      },
      {
        "name": "Heek delight",
        "price": "\u20ac 3,50",
        "recommended": false
      },
      {
        "name": "Rundshamburger",
        "price": "\u20ac 3,20",
        "recommended": false
      },
      {
        "name": "Veg. kaasburger",
        "price": "\u20ac 3,60",
        "recommended": false
      }
    ],
    "soup": {
      "name": "Uiensoep",
      "price": "\u20ac 0,50"
    },
    "vegetables": [
      "Hutsepotgroenten",
      "Bloemkool in kaassaus"
    ]
  }
  }
  ```
