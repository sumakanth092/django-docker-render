# Use official Python image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Create and set working directory
WORKDIR /app

# Install system deps
RUN apt-get update && apt-get install -y build-essential libpq-dev curl && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt /app/
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . /app/

# Create a user (optional, for security)
RUN useradd -m appuser
USER appuser

# Collect static files
ENV DJANGO_SETTINGS_MODULE=config.settings
RUN mkdir -p /home/appuser/staticfiles
RUN python manage.py collectstatic --noinput || true

# Expose port (Render expects 10000 or 8000; we'll use 8000)
EXPOSE 8000

# Use a small entrypoint to run migrations then start gunicorn
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3", "--log-level", "info"]
