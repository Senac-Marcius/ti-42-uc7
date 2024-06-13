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

# Construir a imagem Docker
docker build -t nginx-ssh-ftp-demo .

# Executar o contêiner Docker
docker run -d --network host --dns 8.8.8.8 -p 80:80 -p 21:21 -p 22:22 -p 10050:10050 --name nginx-ssh-ftp-demo-container nginx-ssh-ftp-demo