from datetime import datetime
from datetime import timedelta
import os
import stat
import time

from flask import Flask
from flask import render_template

from cron_converter import Cron
from cron_descriptor import get_description, ExpressionDescriptor

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
        data = scrape_check
        data['last_modification_time'] = last_modification_time
        data['last_modification_time_pretty'] = humanize_date_difference(now=now, otherdate=last_modification_time)
        scrape_status_results.append(data)

    with open(f"{app.config['SCRAPER_DIR']}/hydra.cron", "r") as cronfile:
        for line in cronfile.readlines():
            if line[0] == "#":
                continue
            cron_schedule_str = " ".join(line.split(" ")[:5])
            cron_instance = Cron()
            cron_instance.from_string(cron_schedule_str)
            cron_pretty = ExpressionDescriptor(cron_schedule_str)

            # Raw datetime without timezone info (not aware)
            reference = datetime.now()
            # Get the iterator, initialised to now
            schedule = cron_instance.schedule(reference)
           
            for scraper in scrape_status_results:
                if scraper["cron_scriptname"] in line:
                    scraper["cron_instance"] = cron_instance
                    scraper["cron_pretty"] = cron_pretty
                    scraper["last_scrape_failed"] = schedule.prev() > scraper["last_modification_time"]
                    break


    return render_template(
        'index.html',
        scrape_status_results=scrape_status_results,
    )


if __name__ == "__main__":
    app.run()
