#!/bin/bash

DB_HOST=${DB_PORT_3306_TCP_ADDR:-${DB_HOST}}
DB_HOST=${DB_1_PORT_3306_TCP_ADDR:-${DB_HOST}}
DB_PORT=${DB_PORT_3306_TCP_PORT:-${DB_PORT}}
DB_PORT=${DB_1_PORT_3306_TCP_PORT:-${DB_PORT}}

#if [ "$DB_PASS" = "my-secret-pw" ] && [ -n "$DB_1_ENV_MYSQL_PASS" ]; then
#    DB_PASS="$DB_1_ENV_MYSQL_PASS"
#fi

echo "=> Using the following MySQL/MariaDB configuration:"
echo "========================================================================"
echo "      Database Host Address:  $DB_HOST"
echo "      Database Port number:   $DB_PORT"
echo "      Database Name:          $DB_NAME"
echo "      Database Username:      $DB_USER"
echo "========================================================================"
echo "=> Waiting for database ..."

i=0
while [ "$i" -le 15 ]; do
     DB_CONNECTABLE=$(mysql -u$DB_USER -p$DB_PASS -h$DB_HOST -P$DB_PORT -e 'status' >/dev/null 2>&1; echo "$?")
        if [[ DB_CONNECTABLE -eq 0 ]]; then
            break
        fi
    sleep 3
    i=$(( i + 1 ))
done

if [[ $DB_CONNECTABLE -eq 0 ]]; then
    DB_EXISTS=$(mysql -u$DB_USER -p$DB_PASS -h$DB_HOST -P$DB_PORT -e "SHOW DATABASES LIKE '"$DB_NAME"';" 2>&1 |grep "$DB_NAME" > /dev/null ; echo "$?")

    if [[ DB_EXISTS -eq 1 ]]; then
        echo "=> Creating database $DB_NAME"
        RET=$(mysql -u$DB_USER -p$DB_PASS -h$DB_HOST -P$DB_PORT -e "CREATE DATABASE $DB_NAME")
        if [[ RET -ne 0 ]]; then
            echo "Cannot create database for TYPO3"
            exit RET
        fi
        if [ -f /initial_db.sql ]; then
            echo "=> Loading initial database data to $DB_NAME"
            RET=$(mysql -u$DB_USER -p$DB_PASS -h$DB_HOST -P$DB_PORT $DB_NAME < /initial_db.sql)
            if [[ RET -ne 0 ]]; then
                echo "Cannot load initial database data for TYPO3"
                exit RET
            fi
        fi

        echo "=> Done!"
    else
        echo "=> Skipped creation of database $DB_NAME – it already exists."
    fi
else
    echo "Cannot connect to Mysql"
    exit $DB_CONNECTABLE
fi

if [ ! -f /var/www/html/typo3conf/LocalConfiguration.php ]
    then
        php typo3cms install:setup --non-interactive \
            --database-user-name="tp3min" \
            --database-host-name="$DB_HOST" \
            --database-port="$DB_PORT" \
            --database-name="$DB_NAME" \
            --database-user-password="$DB_PASS" \
            --database-create=0 \
            --admin-user-name="tp3min" \
            --admin-password="Init1111" \
            --site-name="TYPO3 Tests Installation"

        echo "Set permissions for /var/www/html folder ..."
        chown www-data:www-data -R /var/www/html/web/fileadmin /var/www/html/web/typo3temp /var/www/html/web/uploads
fi

# Start apache in foreground if no arguments are given
if [ $# -eq 0 ]
then
    service apache2 start
    service ssh start
fi
