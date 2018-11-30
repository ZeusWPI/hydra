# Deployment

This document outlines the structure and deployment of the Hydra API.

## Requirements

To understand why we do things a certain way, it is useful to understand everything that must
happen.

The Hydra API (and related services for now) entail the following:

- Run tests before potential deployment
    - Tests currently require Python, Node.js and Java
- Process static data
    - Resize images for information
    - Process and copy compatibility files for info
    - Copy everything to the correct location
    - Gather historical resto data (see later)
- Generate data once (or very rarely, perhaps every deployment)
    - Certain resto data such as sandwiches (note that the resto locations are static data)  
      The difference between this and static data scripts is that these might need to be run
      manually.
- Periodically run scrapers
    - Every day for the resto menu. The results of this scraping must be merged with the
      historical data. This historical data must then be saved somewhere. Finally, the new
      data must be copied to the correct location to be accessible.
    - Every hour for urgent.fm
    - Every day or so for Schamper
- Other
    - General config of the server is managed by Ansible.
    - Since the resto website is not always up-to-date, we need to be able to manually run
      the scrapers.
    
The node.js server will move to its own repo, with its own deployment procedure. 
    
### Current strategy

0. Tests are run on Travis CI
1. Manually ssh to the server
2. Pull the latest version of the repo
3. Copy files and run scripts manually as needed

The rest of this document describes the new strategy.

#### Why not capistrano?

- It is yet another language (Ruby)
- The used model (repo folder) it not 100% compatible with what we want.

## Stages

Getting the code from this repo up and running on the server requires multiple steps.

1. Tests
2. _Compiling_
3. Deployment
3. Gathering
4. Scraping
5. Finalising

### Tests

When a pull request is merged into master or a commit is pushed to master, Travis CI will
automatically begin the process.

Before all else, the tests are run. If they fail, the process is stopped. Nothing will happen.
If the tests complete, the next stage is launched.

### _Compiling_ or preparing the static data

The Hydra API contains a fair amount of static data. For an overview of the static data, consult
the structure part of this guide. This data is processed if necessary; the final data is collected
in the output folder.

Examples include resizing the images or copying static HTML files into the correct directory.

This stage is executed on Travis CI.

### Deployment

At this point, the process moves to the actual server. At this point, we run the following:

1. Do some tests to ensure venv is available.
2. Ensure the virtual environment for the scripts is up to date.
3. Create a new directory in the `deploys` folder for the new data, call it `NEW`.
   💎 on 🚊 users will notice this works similarly to capistrano.
   Perhaps it might be faster to copy the current active folder, and `rsync` all new data
   to it? This might be better, since a lot of data probably doesn't change that often.

### Gathering

In this stage, we collect all data for the API.

1. Copy the static data to the `NEW`.
2. Copy all scraper scripts to the `scraper` folder. This includes actual scrapers and scripts
   that are only run on deployment.
3. Run the scripts that are only run on deployment. The output is directly put in `NEW`.
4. Gather the historic resto data. This is done by cloning/pulling the repo containing that
   data.

### Scraping

We run the actual scrapers. Normally these are run by cron, but we run it once manually to ensure
they work. NOTE: this means deployment will fail if the network is down. Perhaps we want to
provide a way to override this?

1. Run the schamper scraper. This is output directly to `NEW`.
2. Run the urgent.fm scraper. This is output directly to `NEW`.
3. Run the resto scraper. This is data is outputted into the repo containing the historical
   resto data.
4. Commit and push the updated resto data. Tag the repo with the name of `NEW`.
   Not only useful, but allows us to undo the commit if necessary.
5. Copy the historical data repo to `NEW`.
5. Back-up existing cron jobs (to undo everything if needed).
6. Schedule the new cron jobs. TODO: is this done by Ansible or not?

### Finalising

Here we publish the new data, do some clean up and exit.

1. Symlink `public` to `new`. At this point, the new version of the API is live.
2. Do some clean-up: remove back-up files (such as the cron job back-up).
3. We only keep one historical API data folder for emergencies. Check if there are older
   ones and remove them.
   
   
## Server folder structure

Some folders are, as indicated, managed by Ansible. Should you wish to change them, it is recommend
you contact a sysadmin for assistance (unless you know what you're doing). 

```
~
├── app
│   └── assistant/public        # node.js server (ansible)
├── deploys                     # contains deploys 
│   ├── 20150080072500
│   └── 20150080073000
│       ├── scraper             # python scraper scripts (~repo in capistrano)
│       │   ├── venv            # virtual environment for python
│       │   ├── resto-data      # historic resto data repo
│       │   ├── *.py            # actual scripts
│       │   └── jobs.cron       # cronjob planning
│       └── public
│           ├── api             # api related stuff (ansible)
│           └── website         # website related stuff (ansible)
├── public -> ~/deploys/20150080073000/public
└── deploys.log                 # contains a log of all deployments and rollbacks
```

## Repo folder structure

To facilitate deployment, the repo is structured similarly to the server.
TODO: this is just a quick sketch; this is not terribly important.

```
server                          # does not include the assistant
├── tests                       # test scripts     
├── static                      # static data and scripts to produce them
├── scraper                     # contains the python files needed to scraper things
└── deployment.sh               # deployment script, run by travis
```

The scripts for the individual steps in the description above are called by `deployment.sh`. All
these scripts should be location independent; there are no guarantees in which working directory
they are called.

All paths passed to scripts should be absolute paths.

TODO: update the document if certain scripts are split into multiple scripts.