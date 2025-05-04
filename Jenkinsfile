pipeline {
    agent any

    tools {
        maven "MAVEN3.9.9"
        jdk "JDK17"
    }

    environment {
        SNAP_REPO = 'vprofile-snapshot'
        NEXUS_USER = 'admin'
        NEXUS_PASS = '1234'
        RELEASE_REPO = 'vprofile-release'
        CENTRAL_REPO = 'vpro-maven-central'
        NEXUSIP = '172.31.18.175'
        NEXUSPORT = '8081'
        NEXUS_GRP_REPO = 'vpro-maven-group'
        NEXUS_LOGIN = 'nexuslogin'
        SONARSERVER = 'sonarserver'
        SONARSCANNER = 'sonarscanner'
    }

    stages {
        stage('Create settings.xml') {
            steps {
                script {
                    writeFile file: 'settings.xml', text: """
<settings>
  <servers>
    <server>
      <id>${SNAP_REPO}</id>
      <username>${NEXUS_USER}</username>
      <password>${NEXUS_PASS}</password>
    </server>
    <server>
      <id>${RELEASE_REPO}</id>
      <username>${NEXUS_USER}</username>
      <password>${NEXUS_PASS}</password>
    </server>
    <server>
      <id>${CENTRAL_REPO}</id>
      <username>${NEXUS_USER}</username>
      <password>${NEXUS_PASS}</password>
    </server>
    <server>
      <id>${NEXUS_GRP_REPO}</id>
      <username>${NEXUS_USER}</username>
      <password>${NEXUS_PASS}</password>
    </server>
  </servers>

  <mirrors>
    <mirror>
      <id>${CENTRAL_REPO}</id>
      <name>${CENTRAL_REPO}</name>
      <url>http://${NEXUSIP}:${NEXUSPORT}/repository/${NEXUS_GRP_REPO}/</url>
      <mirrorOf>*</mirrorOf>
    </mirror>
  </mirrors>
</settings>
"""
                }
            }
        }

        stage('Build') {
            steps {
                sh 'mvn -s settings.xml -DskipTests install'
            }
            post {
                success {
                    echo "Now Archiving"
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }

        stage('Test') {
            steps {
                sh 'mvn -s settings.xml test'
            }
        }

        stage('Checkstyle Analysis') {
            steps {
                sh 'mvn -s settings.xml checkstyle:checkstyle'
            }
        }

        stage('Sonar Analysis') {
    environment {
        scannerHome = tool "${SONARSCANNER}"
    }
    steps {
        withSonarQubeEnv("${SONARSERVER}") {
            sh '''
            ${scannerHome}/bin/sonar-scanner \
            -Dsonar.projectKey=vprofile \
            -Dsonar.projectName=vprofile \
            -Dsonar.projectVersion=1.0 \
            -Dsonar.sources=src \
            -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest \
            -Dsonar.junit.reportsPath=target/surefire-reports \
            -Dsonar.jacoco.reportsPath=target/jacoco.exec \
            -Dsonar.java.checkstyle.reportsPath=target/checkstyle-result.xml
            '''
        }
    }
}
        /*
        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        } */
        

        stage("UploadArtifact") {
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: "${NEXUSIP}:${NEXUSPORT}",
                    groupId: 'QA',
                    version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                    repository: "${RELEASE_REPO}",
                    credentialsId: "${NEXUS_LOGIN}",
                    artifacts: [
                        [
                            artifactId: 'vproapp',
                            classifier: '',
                            file: 'target/vprofile-v2.war',
                            type: 'war'
                        ]
                    ]
                )
            }
        }
        stage("Debug Nexus Upload") {
    steps {
        script {
            echo "Uploading to: http://${NEXUSIP}:${NEXUSPORT}/repository/${RELEASE_REPO}"
            echo "Artifact file exists: ${fileExists('target/vprofile-v2.war')}"
        }
    }
}

    } 
} 
