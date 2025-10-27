#!/bin/bash
# entrypoint.sh — auto migrations + static collection + gunicorn startup

echo "Running Django migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting Gunicorn server..."
exec gunicorn config.wsgi:application --bind 0.0.0.0:8000 --workers 3
