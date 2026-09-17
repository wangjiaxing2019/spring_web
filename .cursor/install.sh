#!/usr/bin/env bash
# Idempotent bootstrap for the springboot_web (Spring Boot 2.2.5 + MySQL) app.
# Runs after the repository is checked out. Safe to run multiple times.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
JAVA8_HOME=/usr/lib/jvm/temurin-8-jdk-amd64

# --- System packages: Temurin JDK 8 (not in Ubuntu 24.04 repos), Maven, MySQL 8 ---
if ! dpkg -s temurin-8-jdk >/dev/null 2>&1 || ! command -v mvn >/dev/null 2>&1 || ! dpkg -s mysql-server >/dev/null 2>&1; then
  sudo install -d -m 0755 /etc/apt/keyrings
  if [ ! -f /etc/apt/keyrings/adoptium.gpg ]; then
    wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public \
      | sudo gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg
  fi
  CODENAME="$(awk -F= '/^VERSION_CODENAME/{print $2}' /etc/os-release)"
  echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb ${CODENAME} main" \
    | sudo tee /etc/apt/sources.list.d/adoptium.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y temurin-8-jdk maven mysql-server ca-certificates wget gnupg apt-transport-https
fi

# --- Spring Boot 2.2.5 targets Java 8; make Temurin 8 the default toolchain ---
for tool in java javac keytool; do
  sudo update-alternatives --install "/usr/bin/${tool}" "${tool}" "${JAVA8_HOME}/bin/${tool}" 20000
  sudo update-alternatives --set "${tool}" "${JAVA8_HOME}/bin/${tool}"
done

# --- Start MySQL so we can seed it (durable state, captured in the snapshot) ---
sudo service mysql start
for _ in $(seq 1 30); do sudo mysqladmin ping >/dev/null 2>&1 && break; sleep 1; done

# --- Root auth: app connects as root/123456 over TCP; Connector/J 5.1.47 needs
#     mysql_native_password (it cannot speak caching_sha2_password). ---
if ! mysql -uroot -p123456 -h127.0.0.1 -e "SELECT 1" >/dev/null 2>&1; then
  sudo mysql <<'SQL'
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456';
FLUSH PRIVILEGES;
SQL
fi

# --- Seed the `springboot` schema and demo data ---
mysql -uroot -p123456 -h127.0.0.1 < src/main/resources/document/springboot.sql

# --- The JDBC URL uses useSSL=true; trust MySQL's auto-generated self-signed CA
#     in the Java 8 truststore so Connector/J's TLS handshake succeeds. ---
sudo cp /var/lib/mysql/ca.pem /tmp/mysql-ca.pem
sudo keytool -delete -alias mysql-auto-ca \
  -keystore "${JAVA8_HOME}/jre/lib/security/cacerts" -storepass changeit >/dev/null 2>&1 || true
sudo keytool -importcert -noprompt -trustcacerts -alias mysql-auto-ca \
  -file /tmp/mysql-ca.pem \
  -keystore "${JAVA8_HOME}/jre/lib/security/cacerts" -storepass changeit

# --- Build the app and run its tests (the mapper test hits the live DB) ---
export JAVA_HOME="${JAVA8_HOME}"
mvn -B clean package
