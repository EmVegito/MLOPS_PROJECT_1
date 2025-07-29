# first get a python image 'slim': lightweight image.
FROM python:slim

# we don't want our environment to overwrite our .pyc files.
ENV PYTHONDONTWRITEBYTECODE = 1 \
    PYTHONUNBUFFERED = 1

WORKDIR /app

# Update all dependencies and install additional dependencies required by lightgbm since recommends download is disabled and
# forcefully and recursivly remove all the package list downloaded from software repositories by APT (Advance Package Tool)
RUN apt-get update && apt-get install -y --no-install-recommends \ 
    libgomp1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy all code from project dir.
COPY . .

# Declare a build argument for the credential file path
ARG GOOGLE_APPLICATION_CREDENTIALS_BUILD_PATH

# Don't install py-chache files and install all other requirements using our setup.py file.
RUN pip install --no-cache-dir -e .

## Run training pipeline
# Set up a conditional RUN command for the training pipeline
# This command will:
# 1. Check if GOOGLE_APPLICATION_CREDENTIALS_BUILD_PATH is provided.
# 2. If it is, copy the key file to a temporary location inside the container.
# 3. Set the GOOGLE_APPLICATION_CREDENTIALS environment variable to that temp path.
# 4. Run your training pipeline.
# 5. Remove the temporary key file.
# This ensures the key is only present during the `RUN` command and not in the final image layer.
RUN if [ -n "${GOOGLE_APPLICATION_CREDENTIALS_BUILD_PATH}" ]; then \
        echo "Running training pipelin with GCP credentials...."; \
        cp "${GOOGLE_APPLICATION_CREDENTIALS_BUILD_PATH}" /tmp/gcp-key.json && \
        export GOOGLE_APPLICATION_CREDENTIALS=/temp/gcp-key.json && \
        python pipeline/training_pipeline.py && \
        rm -f /tmp/gcp-key.json; \
    else \
        echo "WARNING: GOOGLE_APPLICATION_CREDENTIALS_BUILD_PATH not provided. Training pipeline will likely fail if it needs GCP access."; \
    fi

# Expose our flask application Which will run on port: 5000
EXPOSE 5000

# Run our app in application.py file.
CMD ["python", "application.py"]