FROM python:3.12-slim

RUN groupadd -g 1000 flask && \
    useradd -u 1000 -g flask -m -s /bin/bash flask

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN chown -R flask:flask /app

USER flask

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "120", "app:app"]
