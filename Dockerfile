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

# Copy project files
COPY . /app/

# Copy entrypoint and make it executable **before switching user**
COPY entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh

# Create a non-root user and switch
RUN useradd -m appuser
USER appuser

# Prepare static files directory
ENV DJANGO_SETTINGS_MODULE=config.settings
RUN mkdir -p /home/appuser/staticfiles

# Expose port (Render expects 8000)
EXPOSE 8000

# Use entrypoint to run migrations + collectstatic + start gunicorn
ENTRYPOINT ["/app/entrypoint.sh"]
