#!/bin/bash
# entrypoint.sh — auto migrations + static collection + gunicorn startup

echo "Running Django migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Creating Django superuser if not exists..."
python manage.py shell <<EOF
from django.contrib.auth import get_user_model;
User = get_user_model();
if not User.objects.filter(username="admin").exists():
    User.objects.create_superuser("admin", "admin@example.com", "admin123")
    print("Superuser created.")
else:
    print("Superuser already exists.")
EOF

echo "Starting Gunicorn server..."
exec gunicorn config.wsgi:application --bind 0.0.0.0:8000 --workers 3
