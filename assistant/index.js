// See https://github.com/dialogflow/dialogflow-fulfillment-nodejs
// for Dialogflow fulfillment library docs, samples, and to report issues
'use strict';

// Server stuff
const express = require('express');
const bodyParser = require('body-parser');
const fetch = require('node-fetch');

// Import the Dialogflow module from the Actions on Google client library.
const {dialogflow, Table} = require('actions-on-google');

// Instantiate the Dialogflow client.
const app = dialogflow({debug: true});

const RESTO_ENDPOINT_MAP = {
    "De Brug": "nl-debrug",
    "Sint-Jansvest": "nl-sintjansvest",
    "Coupure": "nl",
    "Dunant": "nl",
    "Heymans": "nl-heymans",
    "Merelbeke": "nl",
    "Sterre": "nl",
    "Kantienberg": "nl-kantienberg"
};

// TODO:
// 1. Save the preferred resto (possible once the client library supports it)
// 2. Add things like: 'Find the closest resto'.

/**
 * The intent to show a resto menu to the user.
 *
 * The DialogFlow library automatically handles filling in the parameters for us. We use a webhook, so we can
 * substitute a resto if we saved the resto previously.
 */
app.intent('show-menu', (conv, {resto, date}) => {
    if (RESTO_ENDPOINT_MAP.hasOwnProperty(resto)) {
        conv.data.resto = resto;
        date = new Date(date);
        if (date === undefined || isNaN(date) || date === null) {
            date = new Date();
        }
        const url = constructUrl(RESTO_ENDPOINT_MAP[resto], date);



        fetch(url).then(function (response) {
            if (response.ok) {
                return response.json();
            } else {
                conv.close('Er is geen menu gevonden.');
            }
        }).then(function(json) {
            respondWithJson(json, conv);
        }).catch(reason => {
            conv.close('Er is geen menu gevonden.');
        });
    } else {
        handleRestoNotRecognized(conv, resto);
    }
});

function respondWithJson(json, conv) {
    if (json.open && json.meals !== null && json.meals !== undefined) {
        let names = json.meals
            .filter(m => m.type === 'main')
            .map(m => m.name)
            .join(', ');
        conv.ask('De menu is ' + names);
        const mealRows = json.meals
            .filter((m => m.type === 'main'))
            .map(m => [m.name, m.price]);
        const otherRows = json.meals
            .filter(m => m.type !== 'main')
            .map(m => [m.name, m.price]);
        conv.close(new Table({
            dividers: true,
            columns: ['Item', 'Prijs'],
            rows: mealRows.concat(otherRows),
        }));
    } else {
        conv.close('De resto is gesloten.');
    }
}

function constructUrl(endpoint, date) {
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    return `https://hydra.ugent.be/api/2.0/resto/menu/${endpoint}/${year}/${month}/${day}.json`;
}

function handleRestoNotRecognized(conv, resto) {
    conv.close(`De resto ${resto} ken ik niet. Probeer het opnieuw.`);
}

// Set the DialogflowApp object to handle the HTTPS POST request.
const expressApp = express().use(bodyParser.json());
expressApp.post('/assistant', app);
expressApp.listen(3000);