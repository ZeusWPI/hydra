# Hydra

![hydra-icon-web](https://f.cloud.github.com/assets/5676/46955/0101cef4-58a8-11e2-8b16-06537c38a8cf.png)

Android, iOS, BlackBerry 10 application providing all the information a student at [Ghent University](http://www.ugent.be/) needs. WP coming soon.

This application was developed by [Zeus WPI](http://zeus.ugent.be), the computer science working group. Please contact [hydra@zeus.ugent.be](mailto:hydra@zeus.ugent.be) with any questions.

## Resto API

The scraper pulls the menu from the UGent website and parses into a workable json format. The current API is located at http://zeus.ugent.be/hydra/api/1.0/resto. The number at the end of the URL indicates the version of the API. Currently the API is at version 1.0

The API currently only supports the JSON format.

### Methods provided

* **`meta.json`**

  Some additional information on the UGent resto's such as the legend used and a list of their locations. For each resto a dictionary with 4 values is provided: the `name`, `address`, `latitude` and `longitude`.

* **`menu/[0-9]{4}/[O-9]{2}.json`**

  This resource contains the menus for a whole week. The first number in the URL is the year, the second one is the weeknumber. The list will at most contain 5 entries, one for each day of the week. Each of those entries contains 1 or 4 keys.

  If the `open` key is false, all restos are closed that day and no other keys are provided. If `open` is true, the keys `meat`, `soup` and `vegetables` are also provided.

  An example structure is provided below. This is a typical structure with 4 meat entries, 1 soup entry and 2 vegetable entries.

		"2011-03-21": {
			"open": true,
			"meat": [
				{
					"name": "Kalkoengebraad",
					"price": "\u20ac 2,80",
					"recommended": true
				}, {
					"name": "Heekdelight#",
					"price": "\u20ac 3,50",
					"recommended": false
				}, {
					"name": "Rundshamburger*",
					"price": "\u20ac 3,20",
					"recommended": false
				}, {
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
  The menu data is property of Ghent University. We don't guarantee the correctness or completeness of the data.

## Contributors

In order of first contribution:

* Thomas Meire
* Toon Willems
* Jasper Van der Jeugt
* Pieter De Baets
* Gilles Jacobs
* Jens Panneel
* Tom Naessens
* Yasser Deceukelier
* Feliciaan De Palmenaer
* Arya Ghodsi
* Bart Middag
* Stijn Seghers
