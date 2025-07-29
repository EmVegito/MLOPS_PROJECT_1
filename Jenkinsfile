pipeline {
    agent any

    environment {
        VENV_DIR = 'venv'
        GCP_PROJECT = "carbon-storm-467106-b2"
        GCLOUD_PATH = "/var/jenkins_home/google-cloud-sdk/bin"
        // Add GCLOUD_PATH to PATH for all subsequent sh commands
        PATH = "${PATH}:${GCLOUD_PATH}"
        // Define an image tag dynamically
        // Using BUILD_NUMBER for a simple versioning
        IMAGE_FULL_TAG = "gcr.io/${GCP_PROJECT}/ml-project:01"
    }

    stages {
        stage('Cloning Github Repo to Jenkins') {
            steps {
                script {
                    echo 'Cloning Github Repo to Jenkins...........'
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-token', url: 'https://github.com/aman-yadav-ds/MLOPS_PROJECT_1.git']])
                }
            }
        }

        stage('Setting up our virtual environment and installing dependencies.') {
            steps {
                script {
                    echo 'Setting up our virtual environment and installing dependencies....'
                    sh """
                    #!/bin/bash -xe # Exit on error, echo commands
                    python -m venv ${VENV_DIR}
                    . ${VENV_DIR}/bin/activate
                    pip install --upgrade pip
                    pip install . # Assuming setup.py handles dependencies or use pip install -r requirements.txt
                    """
                }
            }
        }

        stage('Building and Pushing Docker image to GCR(Google Container Registry)') { // Changed GCR to Container Registry
            steps {
                withCredentials([file(credentialsId: 'gcp-key', variable: 'GCP_KEY_FILE_PATH_IN_JENKINS')]) {
                    script {
                        echo 'Building and Pushing Docker image to GCR......'

                        // Option 1: Authenticate gcloud CLI on Jenkins agent
                        // Use withEnv to set GOOGLE_APPLICATION_CREDENTIALS for the gcloud commands
                        withEnv(["GOOGLE_APPLICATION_CREDENTIALS=${GCP_KEY_FILE_PATH_IN_JENKINS}"]) {
                            sh """
                            #!/bin/bash -xe

                            # gcloud will now automatically use the file pointed to by GOOGLE_APPLICATION_CREDENTIALS
                            gcloud auth activate-service-account # No need for --key-file here
                            gcloud config set project ${GCP_PROJECT}
                            gcloud auth configure-docker --quiet
                            """
                        }

                        // Option 2: Build Docker image securely using BuildKit's --secret
                        // This requires the # syntax = docker/dockerfile:1.x line in your Dockerfile
                        sh """
                        #!/bin/bash -xe

                        export DOCKER_BUILDKIT=1 # Ensure BuildKit is enabled

                        docker build \\
                            --secret id=gcp_key,src=${GCP_KEY_FILE_PATH_IN_JENKINS} \\
                            -t ${IMAGE_FULL_TAG} .

                        docker push ${IMAGE_FULL_TAG}
                        """
                    }
                }
            }
        }
        // You might add a stage here for deploying to Cloud Run, GKE, etc.
        // For example:
        // stage('Deploying to Cloud Run') {
        //     steps {
        //         withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
        //             script {
        //                 echo 'Deploying to Cloud Run...'
        //                 sh """
        //                 #!/bin/bash -xe
        //                 gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
        //                 gcloud config set project ${GCP_PROJECT}
        //                 gcloud run deploy ml-project-service --image ${IMAGE_FULL_TAG} \
        //                   --platform managed --region us-central1 --allow-unauthenticated \
        //                   --project ${GCP_PROJECT}
        //                 """
        //             }
        //         }
        //     }
        // }
    }
}