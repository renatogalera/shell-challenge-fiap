
# Shellscript Challenge Helder Fiap - NAC20

[![GitHub last commit](https://img.shields.io/github/last-commit/google/skia.svg)](https://github.com/renatoguilhermini/aula-linux-fiap/commits/master) [![Fiap](https://img.shields.io/badge/Fiap-2018-ff0080.svg)](https://www.fiap.com.br/) [![Linkedin](https://img.shields.io/badge/linkedin-renatoguilhermini-yellowgreen.svg)](https://www.linkedin.com/in/renato-tadeu-galera-guilhermini-31b55614/)


# Iniciando

Script de backup para os diretórios DocumentRoot e configurações do Apache.

# Pré-requisitos

Sistema Operacional Debian ou CentOS/Redhat Enterprise Linux.

# Instalação

```
$ git clone https://github.com/renatoguilhermini/shell-challenge-fiap

$ cd shell-challenge-fiap

$ sudo chmod u+x configure.sh

```
```
$ sudo configure.sh

Programa Backup Apache Conf/Data - Linux Fiap 2019

configure.sh [-c] [-b] [-r] [-v]

Use:
         -c Adiciona tarefa no Crontab
         -b Executa o backup
         -r Executa o restore do backup
         -v Verifica diretórios de backups e logs
         -a Executa backup dos diretórios listados em AUTOBACKUP
```
```
#Executar backup

$ sudo configure.sh -b

#Adicionar crontab

$ sudo configure.sh -c

#Efetuar restore

$ sudo configure.sh -r
```

# Parâmetros

-c adiciona tarefa no crontab. 
Menu interativo, você escolhe hora/minuto.

-b Executa backup automaticamente

-r Restaura backup
Menu interativo, você seleciona a data que deseja o restore

-v Exibe diretórios de Backup e Logs.

-a Executa backup de uma lista de diretórios definidos pela variável AUTOBACKUP

# Backup interativo.

O backup é feito das pastas /var/www, /var/log/{httpd,apache2} /etc/{httpd,apache2}
O modo de compactação é tar com gzip
O backup é gerado com data e hora

# Restore

É possível selecionar a data/hora do restore
O restore é feito no diretório de origem

# Crontab job

Selecione hora/minuto para execução do crontab

# Logs

Logs gerados da execução são salvos no diretório especificado na variável $BACKUPDIR.

# Extras

- Validação e criação das pastas/arquivos logs de backup
- Menu interativo via whiptail para selecionar restore dos backups
- Escolha do horário para execução do Crontab
- Confirmação do restore
- Tratamento dos erros e aviso em caso de falha no processo
