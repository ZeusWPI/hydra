# Resto API 1.0

## Introduction

The resto API provides information about the student restaurants of Ghent University. 

This data is scraped from https://www.ugent.be/student/nl/meer-dan-studeren/resto.

The menu data is property of Ghent University. We don't guarantee the correctness or completeness of the data.

## Versioning and status

This document describes the current version of the API, version 1.0.

| Version                | Endpoint                                   | Status     |
|------------------------|--------------------------------------------|------------|
| 1.0 (this)             | https://zeus.ugent.be/hydra/api/1.0/resto/ | deprecated |
| [2.0](api-resto-02.md) | https://zeus.ugent.be/hydra/api/2.0/resto/ | current    |

## Technical description

* **`meta.json`**

  Some additional information on the resto's such as the legend used and a list of their locations. For each resto a dictionary with 4 values is provided: the `name`, `address`, `latitude` and `longitude`.

* **`menu/[0-9]{4}/[O-9]{2}.json`**

  This resource contains the menus for a whole week. The first number in the URL is the year, the second one is the weeknumber. The list will at most contain 5 entries, one for each day of the week. Each of those entries contains 1 or 4 keys.

  If the `open` key is false, all restos are closed that day and no other keys are provided. If `open` is true, the keys `meat`, `soup` and `vegetables` are also provided.

  An example structure is provided below. This is a typical structure with 4 meat entries, 1 soup entry and 2 vegetable entries.
  ```json
  "2011-03-21": {
    "open": true,
    "meat": [
      {
        "name": "Kalkoengebraad",
        "price": "\u20ac 2,80",
        "recommended": true
      },
      {
        "name": "Heekdelight#",
        "price": "\u20ac 3,50",
        "recommended": false
      },
      {
        "name": "Rundshamburger*",
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
      "Appelcomote"
    ]
  }
  ```
  The menu data is property of Ghent University. We don't guarantee the correctness or completeness of the data.

