# Shellscript Challenge Helder Fiap - NAC20

[![GitHub last commit](https://img.shields.io/github/last-commit/google/skia.svg)](https://github.com/renatoguilhermini/aula-linux-fiap/commits/master) [![Fiap](https://img.shields.io/badge/Fiap-2018-ff0080.svg)](https://www.fiap.com.br/) [![Linkedin](https://img.shields.io/badge/linkedin-renatoguilhermini-yellowgreen.svg)](https://www.linkedin.com/in/renato-tadeu-galera-guilhermini-31b55614/)


# Iniciando

Script de backup para os diretórios DocumentRoot e configurações do Apache.

# Pré-requisitos

Sistema Operacional Debian ou Redhat Enterprise Linux.

# Instalação

```
git clone https://github.com/renatoguilhermini/shell-challenge-fiap

cd shell-challenge-fiap

chmod u+x configure.sh

./configure.sh
    Programa Backup Apache Conf/Data - Linux Fiap 2019

    configure.sh [-c] [-b] [-r]

    Use:
       -c Adiciona tarefa no Crontab
       -b Executa o backup
       -r Executa o restore do backup
```

# Parâmetros

-c adiciona tarefa no crontab. 
Menu interativo, você escolhe hora/minuto e usuário

-b Executa backup automaticamente

-r Restaura backup
Menu interativo, você seleciona a data que deseja o restore

# Backup

O backup é feito das pastas /var/www e /etc/httpd ou /etc/apache2
O modo de compactação é tar com gzip
O backup é gerado com data e hora

# Restore

É possível selecionar a data/hora do restore
O restore é feito no diretório de origem

# Crontab job

Selecione hora/minuto/user para execução do crontab

# Logs

Logs gerados da execução são salvos em logs/log-exec.txt

# Extras

- Validação e criação das pastas de backup
- Menu interativo via whiptail para selecionar restore backup
- Seleção do horário para execução do Crontab
- Confirmação de restore
- Checagem se diretório de backup existe
