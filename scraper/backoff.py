import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

retry_session = requests.Session()
# Try 0.0s, 0.25s, 0.5s, 1s, 2s
retries = Retry(total=5, backoff_factor=0.25)

retry_session.mount('http://', HTTPAdapter(max_retries=retries))
retry_session.mount('https://', HTTPAdapter(max_retries=retries))
