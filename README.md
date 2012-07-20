# Hydra

Android and iOS application providing all the information a student at [Ghent
University](http://www.ugent.be/) needs.

This application was developed by [Zeus WPI](http://zeus.ugent.be), the computer science working group. Please contact [bestuur@zeus.ugent.be](mailto:bestuur@zeus.ugent.be) with any questions.

## API

The scraper pulls the menu from the UGent website and parses into a workable json format. The current API is located at http://zeus.ugent.be/~blackskad/resto/api/0.1/ The number at the end of the URL indicates the version of the API. Currently the API is at version 0.1

The API currently only supports the JSON format.

### Methods provided

* **`list.json`**

  A list of all UGent resto's. For each resto a struct with 4 values is provided: the `name`, `address`, `latitude` and `longitude`.

* **`week/[O-9]{2}.json`**

  This resource contains the menus for a whole week. The number in the URL is the number of the week. The list will at most contain 5 entries, one for each day of the week. Each of those entries contains 1 or 4 keys.

  If the `open` key is false, all restos are closed that day and no other keys are provided. If `open` is true, the keys `meat`, `soup` and `vegetables` are also provided.

  An example structure is provided below. This is a typical structure with 4 meat entries, 1 soup entry and 2 vegetable entries.

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
		}

## Contributors

In alphabetical order:

* Pieter De Baets
* Yasser Deceukelier
* Gilles Jacobs
* Thomas Meire
* Tom Naessens
* Jens Panneel
* Jasper Van der Jeugt
* Toon Willems

## Copyright

Some images are copyright of @jelledelaender and @ccaroline. The icons on the main view are awesome icons by [glyphish](http://glyphish.com). The menu data is property of Ghent University. We don't guarantee the correctness or completeness of the data.
