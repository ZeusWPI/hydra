# Hydra Google Assistant

This is the back-end for the Google Assistant.

It currently only supports asking for the resto menu and only in Dutch.


## Serving

This folder is served as an [express](https://expressjs.com/) server.

## Other

This repo only contains the back-end code. All triggers and other conversational stuff
resides in following services:
 - [Dialogflow](https://dialogflow.com/)
 - [Actions on Google](https://developers.google.com/actions/)

These services use the Hydra Google account. If you want to make changes, discuss them with 
someone from the [Hydra team](https://github.com/orgs/ZeusWPI/teams/hydra) first. If you know 
what you are doing and we are sure you wont mess it up, we'll even provide you access to the 
account so you can change it yourself.