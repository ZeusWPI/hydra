import requests
from requests.packages.urllib3.util.retry import Retry

TIMEOUT = 5  # Time before a request times out
BACKOFF = 0.25  # Try 0.0s, 0.25s, 0.5s, 1s, 2s between requests
AMOUNT = 5  # Amount of request to make before giving up


class TimeoutHTTPAdapter(requests.adapters.HTTPAdapter):
    def __init__(self, timeout=None, *args, **kwargs):
        self.timeout = timeout
        super().__init__(*args, **kwargs)

    def send(self, *args, **kwargs):
        if 'timeout' not in kwargs or kwargs['timeout'] is None:
            kwargs['timeout'] = self.timeout
        return super().send(*args, **kwargs)


retry_session = requests.Session()
retries = Retry(total=AMOUNT, backoff_factor=BACKOFF)

for type in ('http://', 'https://'):
    retry_session.mount(type, TimeoutHTTPAdapter(timeout=5, max_retries=retries))
