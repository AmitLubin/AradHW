# Use official Python base image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install Flask
RUN pip install Flask && \
    pip install authlib werkzeug requests

# Copy app code
COPY app.py .

# Expose port
EXPOSE 3000

# Run the app
CMD ["python", "app.py"]
