# Use a lightweight Python image
FROM python:slim

# Set environment variables to prevent Python from writing .pyc files & Ensure Python output is not buffered
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set the working directory
WORKDIR /app

# Install system dependencies required by LightGBM
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Use --mount=type=secret to securely access the service account key
# The secret is mounted to /run/secrets/gcp_credentials.json (or whatever path you choose)
# and is only available for this RUN command. It's NOT copied into the final image layers.
RUN --mount=type=secret,id=gcp_credentials,dst=/run/secrets/gcp_credentials.json \
    cp /run/secrets/gcp_credentials.json /app/gcp_credentials.json

# Now set the environment variable.
# The JSON file is now at /app/gcp_credentials.json, but it was copied from the secret mount.
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/gcp_credentials.json

# Copy the application code
COPY . .

# Install the package in editable mode
RUN pip install --no-cache-dir -e .

RUN python pipeline/training_pipeline.py

# Expose the port that Flask will run on
EXPOSE 5000

# Default command runs training then app
CMD ["python", "application.py"]