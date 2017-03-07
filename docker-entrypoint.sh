#! /bin/bash

# if we're linked to MySQL and thus have credentials already, let's use them
if [[ -v MYSQL_ENV_GOSU_VERSION ]]; then
    : ${DB_TYPE='mysql'}
    : ${DB_USERNAME:=${MYSQL_ENV_MYSQL_USER:-root}}
    if [ "$DB_USERNAME" = 'root' ]; then
        : ${DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
    fi
    : ${DB_PASSWORD:=$MYSQL_ENV_MYSQL_PASSWORD}
    : ${DB_NAME:=${MYSQL_ENV_MYSQL_DATABASE:-squashtm}}
    : ${DB_URL="jdbc:mysql://mysql:3306/$DB_NAME"}

    xmlstarlet ed \
        -P -S -L \
        -u '/persistence/persistence-unit[@name="openmeetings"]/properties/property[@name="openjpa.ConnectionProperties"]/@value' -v "
        DriverClassName=com.mysql.jdbc.Driver,
        Url=jdbc:$DB_URL?autoReconnect=true&amp;useUnicode=true&amp;createDatabaseIfNotExist=true&amp;characterEncoding=utf-8&amp;connectionCollation=utf8_general_ci&amp;cachePrepStmts=true&amp;cacheCallableStatements=true&amp;cacheServerConfiguration=true&amp;useLocalSessionState=true&amp;elideSetAutoCommits=true&amp;alwaysSendSetIsolation=false&amp;enableQueryTimeouts=false&amp;prepStmtCacheSize=3000&amp;prepStmtCacheSqlLimit=1000&amp;useSSL=false,
        MaxActive=100,
        MaxWait=10000,
        TestOnBorrow=true,
        poolPreparedStatements=true,
        Username=$DB_USERNAME,
        Password=$DB_PASSWORD
        " \
        $OPENMEETINGS_HOME/webapps/openmeetings/WEB-INF/classes/META-INF/mysql_persistence.xml

    if [ -z "$DB_PASSWORD" ]; then
        echo >&2 'error: missing required DB_PASSWORD environment variable'
        echo >&2 '  Did you forget to -e DB_PASSWORD=... ?'
        echo >&2
        echo >&2 '  (Also of interest might be DB_USERNAME and DB_NAME.)'
        exit 1
    fi
fi

# if we're linked to PostgreSQL and thus have credentials already, let's use them
if [[ -v POSTGRES_ENV_GOSU_VERSION ]]; then
    : ${DB_TYPE='postgresql'}
    : ${DB_USERNAME:=${POSTGRES_ENV_POSTGRES_USER:-root}}
    if [ "$DB_USERNAME" = 'postgres' ]; then
        : ${DB_PASSWORD:='postgres' }
    fi
    : ${DB_PASSWORD:=$POSTGRES_ENV_POSTGRES_PASSWORD}
    : ${DB_NAME:=${POSTGRES_ENV_POSTGRES_DB:-squashtm}}
    : ${DB_URL="jdbc:postgresql://postgres:5432/$DB_NAME"}

    xmlstarlet ed \
        -P -S -L \
        -u '/persistence/persistence-unit[@name="openmeetings"]/properties/property[@name="openjpa.ConnectionProperties"]/@value' -v "
        DriverClassName=org.postgresql.Driver,
        Url=jdbc:$DB_URL,
        MaxActive=100,
        MaxWait=10000,
        TestOnBorrow=true,
        poolPreparedStatements=true,
        Username=$DB_USERNAME,
        Password=$DB_PASSWORD
        " \
        $OPENMEETINGS_HOME/webapps/openmeetings/WEB-INF/classes/META-INF/postgresql_persistence.xml

    if [ -z "$DB_PASSWORD" ]; then
        echo >&2 'error: missing required DB_PASSWORD environment variable'
        echo >&2 '  Did you forget to -e DB_PASSWORD=... ?'
        echo >&2
        echo >&2 '  (Also of interest might be DB_USERNAME and DB_NAME.)'
        exit 1
    fi
fi

cd $OPENMEETINGS_HOME

./red5.sh
