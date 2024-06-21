# ti-42-uc7

# Zabbix Deployment


~~~sh
git clone <URL_DO_SEU_REPOSITORIO>
~~~

Este repositório contém os scripts e arquivos necessários para configurar um ambiente Zabbix completo em contêineres Docker, e um ambiente Nginx com SSH, FTP e agente Zabbix em outra VM.

## Estrutura do Projeto

~~~
myproject/
├── Servidor/
│   ├── Dockerfile
│   ├── Deploy.sh
│   ├── zabbix_agentd.conf
│   └── site1/
│       └── index.html
└── Zabbix/
    ├── Deploy.sh
    └── README.md
~~~

## Passos para Configuração

### 1. Configurar o Ambiente Zabbix

#### Clonar o Repositório

Clone o repositório na VM CentOS para configurar o ambiente Zabbix:

~~~sh
cd Zabbix
~~~

#### Tornar o Script Executável

Torne o script `Deploy.sh` executável:

~~~sh
chmod +x Deploy.sh
~~~

#### Executar o Script

Execute o script `deploy_zabbix.sh` para configurar o ambiente Zabbix:

~~~sh
./Deploy.sh
~~~

### 2. Configurar o Ambiente de Servidor

Após configurar o ambiente Zabbix, você precisará do IP da VM onde o Zabbix está rodando. Anote o IP exibido ao final do script `deploy_zabbix.sh`.

#### Clonar o Servidor

Clone o repositório na VM CentOS para configurar o ambiente de portfólio:

~~~sh
cd Servidor
~~~

#### Editar a Configuração do Zabbix Agent

Edite o arquivo `zabbix_agentd.conf` para incluir o IP do servidor Zabbix:

~~~sh
nano zabbix_agentd.conf
~~~

Substitua `<IP_DO_SERVIDOR_ZABBIX>` pelo IP da VM onde o Zabbix está rodando.

#### Tornar o Script Executável

Torne o script `Deploy.sh` executável:

~~~sh
chmod +x Deploy.sh
~~~

#### Executar o Script

Execute o script `Deploy.sh` para configurar o ambiente de portfólio:

~~~sh
./Deploy.sh
~~~

## Configuração do Zabbix Agent

No arquivo `zabbix_agentd.conf`, você deve configurar o servidor Zabbix conforme abaixo:

~~~conf
# Zabbix Agent Configuration
Server=<IP_DO_SERVIDOR_ZABBIX>
Hostname=docker-nginx
~~~

Substitua `<IP_DO_SERVIDOR_ZABBIX>` pelo IP da VM onde o Zabbix está rodando.

## Acesso aos Serviços

### Zabbix Web Interface

Após executar o script `Deploy.sh`, a interface web do Zabbix estará disponível em:

~~~
http://<IP_DA_VM_ZABBIX>:8084
~~~

### Portfólio

Após executar o script `Deploy.sh`, o site de portfólio estará disponível em:

~~~
http://<IP_DA_VM_SERVIDOR>:80
~~~

### Acesso via SSH

Para acessar o contêiner via SSH, utilize:

~~~sh
ssh ubuntu@<IP_DA_VM_SERVIDOR> -p 22
~~~

Usuário: `ubuntu`
Senha: `ubuntu123`

### Acesso via FTP

Para acessar o contêiner via FTP, utilize um cliente FTP (como FileZilla) com as seguintes configurações:

- Host: `<IP_DA_VM_SERVIDOR>`
- Porta: `21`
- Usuário: `ubuntu`
- Senha: `ubuntu123`
