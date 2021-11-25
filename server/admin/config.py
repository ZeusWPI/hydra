import os

PUBLIC_DIR = os.environ.get("PUBLIC_DIR")

if not PUBLIC_DIR:
    raise ValueError("No PUBLIC_DIR set for Flask application")

LAST_SCRAPED_FILE = [{
    'name': 'Resto scraper',
    'last_modified_file_path': 'api/2.0/resto/menu/nl/overview.json',
    'data_url': 'https://hydra.ugent.be/api/2.0/resto/',
    'scrape_interval': 'every day at 10 am and 8 pm'
}, {
    'name': 'Schamper scraper',
    'last_modified_file_path': 'api/1.0/schamper/daily.json',
    'data_url': 'https://hydra.ugent.be/api/1.0/schamper/',
    'scrape_interval': 'every day at 9 am'
}, {
    'name': 'UGent news scraper',
    'last_modified_file_path': 'api/2.0/news/nl.json',
    'data_url': 'https://hydra.ugent.be/api/2.0/news/',
    'scrape_interval': 'every day at 8 am'
}, {
    'name': 'Urgent.fm scraper',
    'last_modified_file_path': 'api/2.0/urgentfm/status.json',
    'data_url': 'https://hydra.ugent.be/api/2.0/urgentfm/',
    'scrape_interval': 'every half hour'
}]
