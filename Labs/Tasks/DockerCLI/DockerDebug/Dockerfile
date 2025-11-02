# syntax=docker/dockerfile:1
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Missing: config.json is NOT copied!
# Need to debug and find this issue

EXPOSE 5000

CMD ["python", "app.py"]
