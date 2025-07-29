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

# Don't install py-chache files and install all other requirements using our setup.py file.
RUN pip install --no-cache-dir -e .

## Run training pipeline
RUN python pipeline/training_pipeline.py

# Expose our flask application Which will run on port: 5000
EXPOSE 5000

# Run our app in application.py file.
CMD ["python", "application.py"]