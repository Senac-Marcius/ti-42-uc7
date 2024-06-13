#!/bin/bash

# Função para verificar a conectividade com a internet
check_internet() {
  wget -q --spider http://google.com
  return $?
}

# Função para reiniciar a interface de rede se a internet não estiver disponível
restart_network() {
  echo "Reiniciando a interface de rede..."
  ifdown enp3s0 && ifup enp3s0
}

# Verificar a conectividade com a internet
if ! check_internet; then
  restart_network
fi

# Verificar novamente a conectividade com a internet
if ! check_internet; then
  echo "Internet não está disponível. Verifique sua conexão."
  exit 1
fi

# Desativar o SELinux
setenforce 0

# Instalar dependências do Docker se não estiverem instaladas
if ! command -v docker &> /dev/null; then
  echo "Instalando Docker..."
  yum install -y yum-utils
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install -y docker-ce docker-ce-cli containerd.io
  systemctl start docker
  systemctl enable docker
fi

# Verificar se o Docker está em execução
if ! systemctl is-active --quiet docker; then
  systemctl start docker
  systemctl enable docker
fi

# Criar rede Docker
docker network create --subnet 172.20.0.0/16 --ip-range 172.20.240.0/20 zabbix-net

# Iniciar instância MySQL
docker run --name mysql-server -t \
  -e MYSQL_DATABASE="zabbix" \
  -e MYSQL_USER="zabbix" \
  -e MYSQL_PASSWORD="zabbix_pwd" \
  -e MYSQL_ROOT_PASSWORD="root_pwd" \
  --network=zabbix-net \
  --restart unless-stopped \
  -d mysql:8.0-oracle \
  --character-set-server=utf8 --collation-server=utf8_bin \
  --default-authentication-plugin=mysql_native_password

# Iniciar Zabbix Java Gateway
docker run --name zabbix-java-gateway -t \
  --network=zabbix-net \
  --restart unless-stopped \
  -d zabbix/zabbix-java-gateway:alpine-6.4-latest

# Iniciar Zabbix Server
docker run --name zabbix-server-mysql -t \
  -e DB_SERVER_HOST="mysql-server" \
  -e MYSQL_DATABASE="zabbix" \
  -e MYSQL_USER="zabbix" \
  -e MYSQL_PASSWORD="zabbix_pwd" \
  -e MYSQL_ROOT_PASSWORD="root_pwd" \
  -e ZBX_JAVAGATEWAY="zabbix-java-gateway" \
  --network=zabbix-net \
  -p 10051:10051 \
  --restart unless-stopped \
  -d zabbix/zabbix-server-mysql:alpine-6.4-latest

# Iniciar Zabbix Web Interface
docker run --name zabbix-web-nginx-mysql -t \
  -e ZBX_SERVER_HOST="zabbix-server-mysql" \
  -e DB_SERVER_HOST="mysql-server" \
  -e MYSQL_DATABASE="zabbix" \
  -e MYSQL_USER="zabbix" \
  -e MYSQL_PASSWORD="zabbix_pwd" \
  -e MYSQL_ROOT_PASSWORD="root_pwd" \
  --network=zabbix-net \
  -p 8084:8080 \
  --restart unless-stopped \
  -d zabbix/zabbix-web-nginx-mysql:alpine-6.4-latest

# Obter o IP da VM
VM_IP=$(hostname -I | awk '{print $1}')

# Exibir o IP da VM
echo "Zabbix Web Interface disponível em http://$VM_IP:8084"
echo "Modifique o arquivo de configuração do portfólio na outra VM para usar o IP: $VM_IP"
