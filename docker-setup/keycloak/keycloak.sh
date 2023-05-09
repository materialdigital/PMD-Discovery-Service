#! /usr/bin/env bash

# DATABASE_PASSWORD="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c"${1:-128}")"
# KEYCLOAK_ADMIN_PASSWORD="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c"${1:-128}")"
# KEYCLOAK_USER_PASSWORD="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c"${1:-128}")"
# PASS_STR="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c"${1:-128}")"
# sed -e "s/\[password\]/${PASS_STR:0:64}/" -e "s/\[db password\]/${PASS_STR:64}/" -e "s/\[admin password\]/${PASS_STR:64}/" templates/keycloak_config.json > config.json

# INITIAL_ACCESS_TOKEN=$(ACCESS_TOKEN=$(docker compose -v run --entrypoint=sh curl -c 'curl -s $KEYCLOAK_URL/realms/$KEYCLOAK_REALM/protocol/openid-connect/token -d client_id=$KEYCLOAK_CLIENT -d grant_type=password -d username=$KEYCLOAK_ADMIN -d password=$KEYCLOAK_ADMIN_PASSWORD' | docker compose run -T jq -r '.access_token') docker compose run --entrypoint=sh curl -c 'curl -s -H "Authorization: Bearer $ACCESS_TOKEN" ${KEYCLOAK_URL}admin/realms/$KEYCLOAK_REALM/clients-initial-access -H "Content-Type: application/json" -d "{ \"count\": 1, \"expiration\": 60 }"' | docker compose run -T jq -r '.token')


#! /bin/sh
# test –f /usr/bin/sshd || exit 0
case "$1" in
    start)
        
        # read passowrds from .env file and check if they are set
        # if not set or empty, generate them
        # if set, use them
        # if passwords are generated, overwrite them inside .env file
        
        . ./.env
        if [ -z "$DATABASE_PASSWORD" ]; then
            echo "Generating passwords"
            PASS_STR="$(shift; < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c"${1:-192}")"
            # split the password string into 3 parts
            # 1. database password
            # 2. admin password
            # 3. user password
            
            DATABASE_PASSWORD=$(echo "$PASS_STR" | cut -c 1-64)
            export DATABASE_PASSWORD
            echo "Database password: $DATABASE_PASSWORD"
            
            KEYCLOAK_ADMIN_PASSWORD=$(echo "$PASS_STR" | cut -c 65-128)
            export KEYCLOAK_ADMIN_PASSWORD
            echo "Admin password: $KEYCLOAK_ADMIN_PASSWORD"
            
            KEYCLOAK_USER_PASSWORD=$(echo "$PASS_STR" | cut -c 129-192)
            export KEYCLOAK_USER_PASSWORD
            echo "User password: $KEYCLOAK_USER_PASSWORD"

            # overwrite the passwords in the .env file
            sed -i -e "s/\(DATABASE_PASSWORD=\).*/\1$DATABASE_PASSWORD/" .env
            sed -i -e "s/\(KEYCLOAK_ADMIN_PASSWORD=\).*/\1$KEYCLOAK_ADMIN_PASSWORD/" .env
            sed -i -e "s/\(KEYCLOAK_USER_PASSWORD=\).*/\1$KEYCLOAK_USER_PASSWORD/" .env

            echo "Passwords generated and saved in .env file for sequential runs"
        fi
        
        
        echo "Starting keycloak"
        docker compose up -d
    ;;
    stop)
        echo "Stopping keycloak"
        docker compose down
    ;;
    clean)
        echo "Removing keycloak junk"
        docker compose down --volumes
    ;;
    #    restart)
    #           ;;
esac