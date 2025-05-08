# Use official Python base image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copy app code
COPY app.py .

# Install Flask
RUN pip install Flask

# Expose port
EXPOSE 3000

# Run the app
CMD ["python", "app.py"]
