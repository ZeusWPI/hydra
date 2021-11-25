FROM python:3.9-alpine

RUN mkdir /app
WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

#CMD flask run --host=0.0.0.0
CMD gunicorn app:app -b 0.0.0.0