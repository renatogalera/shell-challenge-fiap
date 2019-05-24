#!/usr/bin/env bash

#Programas necessários para script rodar
CMDS="tar"
#Definindo Data
DATA=$(date +'%d-%m-%Y-%H-%M-%S')
#Diretório de Backup
BACKUPDIR="/home/backup"
#Diretório específicos de Backups
CONFIGAPACHE=$BACKUPDIR/apache-config
SITESAPACHE=$BACKUPDIR/apache-dados
BACKUPLOGS=$BACKUPDIR/apache-logs
BACKUPAUTO=$BACKUPDIR/backupauto
#Tratando o read
QL=`echo $'\n.'`
QL=${QL%.}
#Arquivos de logs
LOGS=$BACKUPDIR/script-logs
LOGS_BACKUP=$LOGS/backup.txt
LOGS_RESTORE=$LOGS/restore.txt
LOGS_CRONTAB=$LOGS/crontab.txt 
LOGS_AUTO=$LOGS/auto-backup.txt
TAR_BKP='/bin/tar -cvPpzf'
TAR_REST='/bin/tar -xvPpzf'

#Criar um backup diferenciado automático, usando a lista abaixo.
AUTOBACKUP="
    /var/log
    /etc
    /usr/lib
    /var/spool
    "

#Função tratar erro
function trataErro()
{
    if [ $? = 0 ];
    then
        echo "#### $FUNCAO finalizado(a) com sucesso" 
    else
        echo "#### Erro ao realizar $FUNCAO"
    fi
}

#Função vars Centos
function varsCentos()
{
    OSVERSION="centos"
    APACHEDIR="/etc/httpd"
    APACHEDOCROOT="/var/www/"
    LOGS_APACHE="/var/log/httpd"

}

#Função vars Debian
function varsDebian()
{
    OSVERSION="debian"
    APACHEDIR="/etc/apache2"
    APACHEDOCROOT="/var/www/"
    LOGS_APACHE="/var/log/apache2"
}

#Função Help
function comoUsa()
{
    echo "Programa Backup Apache Conf/Data - Linux Fiap 2019"
    echo ""
    echo "$(basename "$0") [-c] [-b] [-r] [-v]"
    echo ""
    echo "Use:"
    echo -e "\t -c Adiciona tarefa no Crontab"
    echo -e "\t -b Executa o backup"
    echo -e "\t -r Executa o restore do backup"
    echo -e "\t -v Verifica diretórios de backups e logs"
    echo -e "\t -a Executa backup dos diretórios listados em AUTOBACKUP"
}

#Função restore Backup
function menuRestoreBackup()
{
    echo "   1) Restaurar backup das Configurações do Apache"
    echo "   2) Restaurar backup Sites do Apache"
    echo "   3) Restaurar backup dos Logs Apache"
    echo "   4) Sair"
    until [[ "$SELECT_RESTORE" =~ ^[1-4]$ ]]; do
        read -rp "Selecione uma opção [1-4]: " SELECT_RESTORE
    done
    case $SELECT_RESTORE in
        1)
            TITULO="Restore da Configuração do Apache"
            RESTAURE=$CONFIGAPACHE
            restoreBackup
        ;;
        2)
            TITULO="Restore Sites/WWW"
            RESTAURE=$SITESAPACHE
            restoreBackup
        ;;
        3)
            TITULO="Restore Logs Apache"
            RESTAURE=$BACKUPLOGS
            restoreBackup
        ;;
        4)
            echo "Saindo..."
            exit 1
        ;;
    esac
}

function restoreBackup()
{
    if [ ! -z $RESTAURE ];
    then
        ESCOLHA_DATA=$(whiptail --title "$TITULO" --menu "Escolha data do backup" 20 78 10 `for x in $RESTAURE/*.tar.gz; do echo "$x Backup" | sed 's/.*apache-\(.*\).tar.gz/\1/'; done` 3>&1 1>&2 2>&3)
        ESCOLHA_DATA=$(ls $RESTAURE/apache-"$ESCOLHA_DATA".tar.gz| tail -n 1)
            if [[ -z $ESCOLHA_DATA ]];then
                echo "Não foi encontrado arquivo de backup"
                exit 1
            else
                read -rp "Deseja restaurar backup ? $QL $ESCOLHA_DATA $QL (S para SIM): " OKRESTORE
                    if [ "$OKRESTORE" != "${OKRESTORE#[Ss]}" ] ;
                    then
                        echo "############## Restore iniciado em $DATA"
                        $TAR_REST $ESCOLHA_DATA -C / 
                        trataErro
                    else
                        echo "Não foi selecionado S [SIM], saindo ..."  
                        exit 1
                    fi                            
            fi
    else
        echo "Diretório de Backup não encontrado"
        exit 1
    fi
}

#Função checa versão sistema operacional
function checaVersaoOS()
{
    if /bin/grep -iqs 'rhel' /etc/*release;
    then
        varsCentos
    elif grep -iqs 'debian' /etc/*release;
    then
        varsDebian
    else
        echo "Script funciona apenas em RHEL/Debian"
        exit 1
    fi
}

#Função add crontab
function addCrontab()
{
    read -rp "Digite Hora [0-23]: " SETHORA
    read -rp "Digite Minutos [0-59]: " SETMINUTO
    /bin/cp $(basename "$0") $BACKUPDIR
    /bin/chown $SETUSER $BACKUPDIR/$(basename "$0")
    /bin/chmod 700 $BACKUPDIR/$(basename "$0")
    echo "$SETMINUTO $SETHORA 0 0 0 $SETUSER $BACKUPDIR/$(basename "$0") -b" >> /etc/crontab
    echo ""
    echo "######CRIAÇÃO CRONTAB######" 
    echo "$SETMINUTO $SETHORA 0 0 0 root $BACKUPDIR/$(basename "$0") -b" 
    trataErro 
}

#Função checar pastas backup
function checaFolders()
{
    FOLDERSOK=(
        $BACKUPDIR
        $CONFIGAPACHE
        $SITESAPACHE
        $LOGS
        $BACKUPLOGS
        $BACKUPAUTO )
    
    for f in "${FOLDERSOK[@]}";
    do
        if [ ! -e $f ];
        then
            echo "Pasta não encontrada, criando: " $f
            mkdir $f
        fi
    done

    FILESOK=(
        $LOGS_BACKUP
        $LOGS_RESTORE
        $LOGS_CRONTAB
        $LOGS_AUTO )
    for f in "${FILESOK[@]}";
    do
        if [ ! -e $f ];
        then
            echo "Arquivo não encontrado, criando: " $f
            touch $f
        fi
    done
}

#Checando programas
function checaProgramas()
{
    for i in $CMDS
    do
        command -v $i >/dev/null && continue || { echo "$i Comando não encontrado, instale para prosseguir."; exit 1; }
    done
}

#Função executando backup
function execBackup()
{
    echo "#################"
    echo "## Iniciando Backup $DATA" 
    echo "## Backup das configurações do Apache" 
    echo "#################"
    $TAR_BKP $CONFIGAPACHE/apache-config-$DATA.tar.gz $APACHEDIR 
    echo "#################" 
    echo "## Backup dados dos sites Apache em $SITESAPACHE/apache-data-$DATA.tar.gz" 
    echo "#################"
    $TAR_BKP $SITESAPACHE/apache-data-$DATA.tar.gz $APACHEDOCROOT 
    echo "#################"
    echo "## Backup dos logs Apache em $BACKUPLOGS/apache-logs-$DATA.tar.gz"
    echo "#################"
    $TAR_BKP $BACKUPLOGS/apache-logs-$DATA.tar.gz $LOGS_APACHE 
    trataErro
}

function autoBackup()
{
    echo "#################"
    echo "## Iniciando Backup Automático $DATA"
    echo "#################"
    $TAR_BKP $BACKUPAUTO/auto-backup-$DATA.tar.gz $AUTOBACKUP
    trataErro
}

#Função principal
function Main()
{
    checaVersaoOS
    checaProgramas
    checaFolders
}

#Argumentos de execução
case "$1" in
    "-c")
    FUNCAO="Adicionando ao Crontab"
    exec &> >(tee -a "$LOGS_CRONTAB")
    exec 2>&1 
    addCrontab
    ;;
    "-b")
    FUNCAO="Executando Backup"
    exec &> >(tee -a "$LOGS_BACKUP")
    exec 2>&1
    Main
    execBackup
    ;;
    "-r")
    FUNCAO="Restaurando o Backup"
    exec &> >(tee -a "$LOGS_RESTORE")
    exec 2>&1
    menuRestoreBackup
    ;;
    "-v")
    echo "Diretório de backup: $BACKUPDIR"
    echo "Diretório de logs: $LOGS"
    ;;
    "-a")
    exec &> >(tee -a "$LOGS_AUTO")
    exec 2>&1
    Main
    autoBackup
    ;;
    *) 
    echo "Opção Inválida" >&2
    comoUsa >&2
    exit 1
    ;;
esac

#Checa Args 1
if [ -z $1 ]; then
    comoUsa
fi
