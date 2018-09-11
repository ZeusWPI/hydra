# Hydra web services

Overview of the code that powers all Hydra-related things online.

## Overview

* General resources (art and such) are in the [`resources`](../resources) folder.
* The code/resources/scripts are located in the [`app`](../server) folder:
    * [API](#api)
    * [Assistant folder](#assistant)
    * [Deployment](#deployment)
    * [Tests](#tests)
    * [Website folder](#website)

### API

Located at [`api`](../server/api).

Scripts and data that power the Hydra `api`. The scripts are written in Python.

Documentation for API users is [here](api.md).

### Assistant

Located at [`assistant`](../server/assistant).

The back-end for the Google Assistant. It currently only supports asking for the resto menu
and only in Dutch.

#### Serving

This folder is served as an [express](https://expressjs.com/) server.

#### Other

This repo only contains the back-end code. All triggers and other conversational stuff
resides in following services:
 - [Dialogflow](https://dialogflow.com/)
 - [Actions on Google](https://developers.google.com/actions/)

These services use the Hydra Google account. If you want to make changes, discuss them with 
someone from the [Hydra team](https://github.com/orgs/ZeusWPI/teams/hydra) first. If you know 
what you are doing and we are sure you wont mess it up, we'll even provide you access to the 
account so you can change it yourself.


### Deployment

Contains scripts to run on the server to deploy and set up the server.
These are used by Travis to deploy the repo.


### Website
Located at [`website`](../server/website).

The Hydra website, live at [https://hydra.ugent.be](https://hydra.ugent.be) or 
[http://student.ugent.be/hydra](http://student.ugent.be/hydra).


### Tests
Located at [`app/tests`](../server/tests).

Contains all the tests that are run by Travis when making a PR or on the master branch.

