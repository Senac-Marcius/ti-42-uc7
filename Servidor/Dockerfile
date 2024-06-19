# Usando a imagem base do Nginx
FROM nginx:latest

# Instalar o SSH
RUN apt-get update && apt-get install -y openssh-server

# Criar e configurar o usuário SSH
RUN useradd -ms /bin/bash ubuntu && echo 'ubuntu:ubuntu123' | chpasswd

# Configurar o SSH para não permitir login de root e permitir login de ubuntu
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
	&& sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
	&& mkdir /var/run/sshd

# Copiar os arquivos do site
COPY site1 /usr/share/nginx/html

# Atualizar a lista de pacotes e instalar FTP
RUN apt-get install -y vsftpd 

# Configurar o FTP
RUN sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf \
    && echo "local_enable=YES" >> /etc/vsftpd.conf \
    && echo "chroot_local_user=YES" >> /etc/vsftpd.conf

# Instalar o Zabbix Agent
RUN apt-get install -y zabbix-agent

# Configurar o Zabbix Agent
COPY zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf

# Expor as portas 80, 21 (FTP), 22 (SSH) e 10050 (Zabbix Agent)
EXPOSE 81 21 22 10050
# Iniciar o SSH, FTP, Zabbix Agent e o Nginx
CMD ["/bin/bash", "-c", "service ssh start && service vsftpd start && service zabbix-agent start && nginx -g 'daemon off;'"]
