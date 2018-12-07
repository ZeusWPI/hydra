# Testing

## Basic tests

Basic tests are run by Travis on PRs and on master.

## Full deployment + scrapers

You can run the full deployment (including the scrapers) by providing the `server/deploy.sh` script
with a second parameter, i.e.
```bash
$ ./server/deploy.sh ./server/ ./deploytest
```

This will deploy the API data to the `deploytest` folder. This will only run locally and won't
affect remote servers. For example, the repo with historic resto data is not updated.

| ⚠️ WARNING: this will set cron jobs on your local system |
|---|

Don't forget to disable the cron jobs afterwards.

| ⚠️ WARNING: this will affect your local Python install |
|---|

While the _remote_ parts of the script use a contained venv to manage Python dependencies,
the local parts do not; they require at least Python 3 (test with 3.7). Dependencies will
be installed. If you don't want this, you should probably activate a venv manually before
running the script (not tested though).