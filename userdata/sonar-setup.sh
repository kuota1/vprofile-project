#!/bin/bash

# Ajustes de sistema
sysctl -w vm.max_map_count=262144
echo "fs.file-max = 65536" >> /etc/sysctl.conf

echo "sonarqube   -   nofile   65536" >> /etc/security/limits.conf
echo "sonarqube   -   nproc    4096" >> /etc/security/limits.conf

# Instalación de Java
apt-get update -y
apt-get install openjdk-17-jdk zip -y

# Instalación y configuración de PostgreSQL
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
apt-get update
apt-get install postgresql postgresql-contrib -y

systemctl enable postgresql
systemctl start postgresql

echo "postgres:admin123" | chpasswd

sudo -u postgres psql <<EOF
CREATE USER sonar WITH ENCRYPTED PASSWORD 'admin123';
CREATE DATABASE sonarqube OWNER sonar;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;
EOF

# Descarga e instalación de SonarQube
mkdir -p /sonarqube/
cd /sonarqube/
curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.8.100196.zip
unzip -o sonarqube-9.9.8.100196.zip -d /opt/
mv /opt/sonarqube-9.9.8.100196 /opt/sonarqube

# Usuario y permisos
groupadd sonar
useradd -c "SonarQube - User" -d /opt/sonarqube/ -g sonar sonar
chown -R sonar:sonar /opt/sonarqube/

# Configuración de SonarQube
cat <<EOT > /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=admin123
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.web.javaAdditionalOpts=-server
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
sonar.log.level=INFO
sonar.path.logs=logs
EOT

# Servicio systemd para SonarQube
cat <<EOT > /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable sonarqube.service

# Instalación de Nginx
apt-get install nginx -y
rm -rf /etc/nginx/sites-enabled/default
rm -rf /etc/nginx/sites-available/default

cat <<EOT > /etc/nginx/sites-available/sonarqube
server {
    listen 80;
    server_name _;

    access_log  /var/log/nginx/sonar.access.log;
    error_log   /var/log/nginx/sonar.error.log;

    proxy_buffers 16 64k;
    proxy_buffer_size 128k;

    location / {
        proxy_pass  http://127.0.0.1:9000;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;
              
        proxy_set_header    Host            \$host;
        proxy_set_header    X-Real-IP       \$remote_addr;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto http;
    }
}
EOT

ln -s /etc/nginx/sites-available/sonarqube /etc/nginx/sites-enabled/sonarqube
systemctl enable nginx

# Abrir puertos en UFW (si se usa)
# ufw allow 80,9000,9001/tcp

echo "Instalación finalizada. Reiniciando en 30 segundos..."
sleep 30
reboot


#this need a database I used a postgress, and need a service forn-end nginx. so, the user come in ngnix, ngnix route 
#to sonar and sonar used a postgress
# Ubuntu t2 Medium