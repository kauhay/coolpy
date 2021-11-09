#!/usr/bin/env bash
#_____________________________________________________________________________#
# AUTOR: Selton kauhay barros da silva <seltonkauhay@gmail.com>
# DESCRIÇÃO: Backup de arquivos, diretórios e banco de dados do MariaDB
# Versão: 1.0
# Descrição: 
#_____________________________________________________________________________#

#_____________________________ Backup de Arquivos __________________________________#
# Esta é a sessão para backup de arquivos! Para ativar o backup de arquivos

# Para desativar backup altere a chave abaixo para false.
BACKUP_FILES=true
# Selecione os diretorios que deseja fazer backup
# A adicione o caminho absoluto do diretório e retire o comentário '#'.
SOURCE_DIRS=(
#    '/diretorio/deretorio2/bkp1'
#    '/diretorio/deretorio2/bkp2'
#    '/diretorio/deretorio2/bkp3'
)
# Caso precise pular alguns diretórios na hora do backup
# adicione o caminho absoluto aqui, como no exemplo.
# Exemplo: '--exclude=/diretorio/diretorio2/bkp1/arq/'
# Neste caso o diretório Downloads do usuário não entrará no backup.
EXCLUDE_DIRS=(
#    '--exclude=/diretorio/diretorio2/bkp1/arq/'
#    '--exclude=/diretorio/diretorio2/bkp1/arq2/'
#    '--exclude=/diretorio/diretorio2/bkp1/arq3/'
)

#_____________________________ Backup de Bando de dados __________________________________#
# Esta é a sessão para backup do banco de dados! Para desativar altere a chave abaixo para false.
BACKUP_DB=true

# Usuário do banco de dados.
user='usuario do banco'

# Password do banco de dados
password='senha do banco'

#_____________________________ Variaveis __________________________________#

# Qunatidfade de dias que quer manter os arquivos de backups.
KEEP_DAY='7'

# Diretorio aonde será salvo o backup.
BACKUP_DIR='/var/bkpdb'

# O log sera registrado aqui
LOG='/var/bkpdb/log/mariadb.log'

# Formato de  Data e Hora para utilizar no nome do backup.
# O padrao e: (dd-mm-aaaa)
DATE="$(date +%d-%b-%Y)"

#_____________________________ Verificações __________________________________#

# Verificando se diretorio para backup foi criado.
[ ! -d $BACKUP_DIR ] && mkdir $BACKUP_DIR

#______________ FUNÇÕES ______________________________________________________#
die() { echo "$@" >>${LOG}; exit 1 ;}

#______________ INICIO _______________________________________________________#

# Backup para arquivos de do diretorio de backup
if [ "$BACKUP_FILES" = 'true' ]; then
    tar ${EXCLUDE_DIRS[@]} -cpzf "${BACKUP_DIR}/daily_backup-${DATE}.tar.gz" "${SOURCE_DIRS[@]}" || die "------ $(date +'%d-%m-%Y %T') Backup Diretorios [ERRO]"
    echo "-- $(date +'%d-%m-%Y %T') Backup do Diretorio [SUCESSO]" >>${LOG}
fi

# Exportação dos arquivos do banco de dados
if [ "$BACKUP_DB" = 'true' ]; then
    sqlfile="mariadb_${DATE}.sql" # Nome temporario d oarquivo exportado do banco.
    mysqldump -u "$user" -p"$password" --all-databases > ${BACKUP_DIR}/$sqlfile 2>>${LOG} || die "------ $(date +'%d-%m-%Y %T') Backup database [ERRO]"
    tar cJf "${BACKUP_DIR}/mariadb_${DATE}.tar.gz" ${BACKUP_DIR}/$sqlfile && rm ${BACKUP_DIR}/$sqlfile
    echo "-- $(date +'%d-%m-%Y %T') Backup do banco e dados [SUCESSO]" >>${LOG}
fi

# Checagem de Backups mais antigos que N dias.
# Se existirem serão removidos.
find "$BACKUP_DIR" -mtime "$KEEP_DAY" -delete