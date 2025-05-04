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
                sh 'mvn test'
            }
        }

        stage('Checkstyle Analysis') {
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }
    }
}
