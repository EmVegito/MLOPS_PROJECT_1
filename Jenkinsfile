pipeline{
    agent any
    
    environment {
        VENV_DIR = 'venv'
        GCP_PROJECT = "carbon-storm-467106-b2"
        GCLOUD_PATH = "/var/jenkins_home/google-cloud-sdk/bin"
    }

    stages{
        stage('Cloning Github Repo to Jenkins'){
            steps{
                script{
                    echo 'Cloning Github Repo to Jenkins...........'
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-token', url: 'https://github.com/aman-yadav-ds/MLOPS_PROJECT_1.git']])
                }
            }
        }
        
        stage('Setting up our virtual environment and installing dependencies.'){
            steps{
                script{
                    echo 'Setting up our virtual environment and installing dependencies....'
                    sh '''
                    python -m venv ${VENV_DIR}
                    . ${VENV_DIR}/bin/activate
                    pip install --upgrade pip
                    pip install -e .
                    '''
                }
            }
        }
        
        stage('Building and Pushing Docker image to GCR(Google Cloud Run)'){
            steps{
                withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]){
                    script{
                        echo 'Building and Pushing Docker image to GCR......'
                        sh '''
                        export PATH=$PATH:${GCLOUD_PATH}

                        gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}

                        gcloud config set project ${GCP_PROJECT}

                        gcloud auth configure-docker --quiet

                        docker build -t gcr.io/${GCP_PROJECT}/ml-project:01 .

                        docker push gcr.io/${GCP_PROJECT}/ml-project:01
                        '''
                    }
                }
            }
        }
    }
}