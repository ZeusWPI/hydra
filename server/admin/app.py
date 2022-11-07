from datetime import datetime
from datetime import timedelta
import os
import stat
import time

from flask import Flask
from flask import render_template

import config
from datedifference import humanize_date_difference

# Create Flask's `app` object
app = Flask(__name__)
app.config.from_object('config')


@app.route('/')
def home():
    """Landing page."""

    now = datetime.now()
    scrape_status_results = []
    for scrape_check in app.config['LAST_SCRAPED_FILE']:
        file_stats = os.stat(f"{app.config['PUBLIC_DIR']}/{scrape_check['last_modified_file_path']}")

        last_modification_time = datetime.fromtimestamp(file_stats[stat.ST_MTIME])
        last_modification_time_pretty = humanize_date_difference(
            now=now,
            otherdate=last_modification_time)
        data = scrape_check
        data['last_modification_time'] = last_modification_time_pretty
        data['scrape_failed_for_1_day'] = (now - last_modification_time) > timedelta(days=1)
        scrape_status_results.append(data)

    return render_template(
        'index.html',
        scrape_status_results=scrape_status_results
    )


if __name__ == "__main__":
    app.run()
