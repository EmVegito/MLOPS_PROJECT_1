pipeline{
    agent any

    environment {
        VENV_DIR = 'venv'
        GCP_PROJECT = "carbon-storm-467106-b2"
        GCLOUD_PATH = "/var/jenkins_home/google-cloud-sdk/bin"
        IMAGE_TAG = "gcr.io/${GCP_PROJECT}/ml-project:01"
    }

    stages{
        stage('Cloning Github repo to Jenkins'){
            steps{
                script{
                    echo 'Cloning Github repo to Jenkins............'
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-token', url: 'https://github.com/aman-yadav-ds/MLOPS_PROJECT_1.git']])
                }
            }
        }

        stage('Setting up our Virtual Environment and Installing dependancies'){
            steps{
                script{
                    echo 'Setting up our Virtual Environment and Installing dependancies............'
                    sh '''
                    python -m venv ${VENV_DIR}
                    . ${VENV_DIR}/bin/activate
                    pip install --upgrade pip
                    pip install -e .
                    '''
                }
            }
        }

        stage('Building Docker Image'){
            steps{
                withCredentials([file(credentialsId: 'gcp-key' , variable : 'GOOGLE_APPLICATION_CREDENTIALS')]){
                    script{
                        echo 'Building Docker Image.............'
                        sh '''
                        export PATH=$PATH:${GCLOUD_PATH}

                        gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
                        gcloud config set project ${GCP_PROJECT}
                        gcloud auth configure-docker --quiet

                        # Build Docker image WITHOUT credentials
                        docker build -t ${IMAGE_TAG} .
                        '''
                    }
                }
            }
        }

        stage('Run Training and Application with Credentials'){
            steps{
                withCredentials([file(credentialsId: 'gcp-key' , variable : 'GOOGLE_APPLICATION_CREDENTIALS')]){
                    script{
                        echo 'Running Training Pipeline and Application with GCP credentials.............'
                        sh '''
                        # Run the container with mounted credentials
                        # This will run training first, then start the Flask app
                        docker run --rm -d --name ml-pipeline \
                            -p 8080:8080 \
                            -v "${GOOGLE_APPLICATION_CREDENTIALS}":/tmp/gcp-credentials.json:ro \
                            -e GOOGLE_APPLICATION_CREDENTIALS=/tmp/gcp-credentials.json \
                            ${IMAGE_TAG}
                        
                        # Wait for training to complete and app to start
                        echo "Waiting for training to complete and app to start..."
                        sleep 60
                        
                        # Check if the app is running
                        docker logs ml-pipeline
                        
                        # Optionally test the app
                        # curl -f http://localhost:8080/ || echo "App not ready yet"
                        
                        # Stop the container (or leave it running for deployment)
                        docker stop ml-pipeline
                        '''
                    }
                }
            }
        }

        stage('Pushing Docker Image to GCR'){
            steps{
                withCredentials([file(credentialsId: 'gcp-key' , variable : 'GOOGLE_APPLICATION_CREDENTIALS')]){
                    script{
                        echo 'Pushing Docker Image to GCR.............'
                        sh '''
                        export PATH=$PATH:${GCLOUD_PATH}

                        gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
                        gcloud config set project ${GCP_PROJECT}

                        # Push the image to GCR
                        docker push ${IMAGE_TAG}
                        '''
                    }
                }
            }
        }
        
    }
}