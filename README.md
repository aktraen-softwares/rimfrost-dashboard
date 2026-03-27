# Rimfrost Dashboard

Analytics dashboard platform for Rimfrost Analytics.

## Quick Start

```bash
docker compose up -d
```

The application will be available at `http://dash.rimfrost.com`.

## Architecture

- **Flask** web application serving the dashboard UI
- **PostgreSQL 16** for data persistence
- **Gunicorn** as the WSGI server in production

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `DATABASE_URL` | `postgresql://rimfrost:rimfrost_db_pass_2026@db:5432/rimfrost` | PostgreSQL connection string |
| `SECRET_KEY` | `rimfrost_super_secret_2026` | Flask secret key for sessions |
| `FLASK_ENV` | `production` | Flask environment |

## Development

```bash
pip install -r requirements.txt
export DATABASE_URL="postgresql://rimfrost:rimfrost_db_pass_2026@localhost:5432/rimfrost"
export SECRET_KEY="rimfrost_super_secret_2026"
python app.py
```
