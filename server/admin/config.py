import os

PUBLIC_DIR = os.environ.get("PUBLIC_DIR")
SCRAPER_DIR = os.environ.get("SCRAPER_DIR")

if not PUBLIC_DIR:
    raise ValueError("No PUBLIC_DIR set for Flask application")
if not SCRAPER_DIR:
    raise ValueError("No SCRAPER_DIR set for Flask application")

LAST_SCRAPED_FILE = [{
    'name': 'Resto scraper',
    'last_modified_file_path': 'api/2.0/resto/menu/nl/overview.json',
    'data_url': 'https://hydra.ugent.be/api/2.0/resto/',
    'cron_scriptname': "resto.sh",
}, {
    'name': 'Schamper scraper',
    'last_modified_file_path': 'api/1.0/schamper/daily.json',
    'data_url': 'https://hydra.ugent.be/api/1.0/schamper/',
    'cron_scriptname': "schamper.py",
}, {
    'name': 'UGent news scraper',
    'last_modified_file_path': 'api/2.0/news/nl.json',
    'data_url': 'https://hydra.ugent.be/api/2.0/news/',
    'cron_scriptname': "news.py",
}, {
    'name': 'Urgent.fm scraper',
    'last_modified_file_path': 'api/2.0/urgentfm/status.json',
    'data_url': 'https://hydra.ugent.be/api/2.0/urgentfm/',
    'cron_scriptname': "urgentfm.py",
}]
