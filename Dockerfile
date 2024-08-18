# Use an official Python runtime as a parent image
FROM python:3.12-slim as base

# Set the working directory in the container
WORKDIR /app

FROM base as dependencies
# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    build-essential \
    pkg-config \
    libhdf5-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

    
# Install any needed packages specified in requirements.txt
FROM dependencies as install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
    
FROM install as release
# Copy the current directory contents into the container at /app
COPY . .

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 CMD [ "curl", "-f", "http://localhost:8000/v1/status", "||", "exit 1" ]

# Command to run the Uvicorn server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]