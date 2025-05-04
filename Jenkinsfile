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
                writeFile file: 'settings.xml', text: """
<settings>
  <servers>
    <server>
      <id>${env.SNAP_REPO}</id>
      <username>${env.NEXUS_USER}</username>
      <password>${env.NEXUS_PASS}</password>
    </server>
    <server>
      <id>${env.RELEASE_REPO}</id>
      <username>${env.NEXUS_USER}</username>
      <password>${env.NEXUS_PASS}</password>
    </server>
    <server>
      <id>${env.CENTRAL_REPO}</id>
      <username>${env.NEXUS_USER}</username>
      <password>${env.NEXUS_PASS}</password>
    </server>
    <server>
      <id>${env.NEXUS_GRP_REPO}</id>
      <username>${env.NEXUS_USER}</username>
      <password>${env.NEXUS_PASS}</password>
    </server>
  </servers>

  <mirrors>
    <mirror>
      <id>${env.CENTRAL_REPO}</id>
      <name>${env.CENTRAL_REPO}</name>
      <url>http://${env.NEXUSIP}:${env.NEXUSPORT}/repository/${env.NEXUS_GRP_REPO}/</url>
      <mirrorOf>*</mirrorOf>
    </mirror>
  </mirrors>
</settings>
"""
            }
        }

        stage('Build') {
            steps {
                sh 'mvn -s settings.xml -DskipTests install'
            }
        }
    }
}
