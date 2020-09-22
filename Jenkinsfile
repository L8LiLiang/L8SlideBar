pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                sh 'python --version'
		sh './fail'
            }
        }
        stage('Test') {
            steps {
		echo "Testing"
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying'
            }
        }
    }

    post {
        always {
            echo 'One way or another, I have finished'
            deleteDir() /* clean up our workspace */
        }
        success {
            echo 'I succeeded!'
        }
        unstable {
            echo 'I am unstable :/'
        }
        failure {
            echo 'I failed :('
        }
        changed {
            echo 'Things were different before...'
        }
    }
}


