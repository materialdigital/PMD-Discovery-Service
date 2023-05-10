#! /bin/sh
case "$1" in
    start)
        
        # read passowrds from .env file and check if they are set
        # if not set or empty, generate them
        # if set, use them
        # if passwords are generated, overwrite them inside .env file
        
        . ./.env
        if [ -z "$DATABASE_PASSWORD" ] || [ -z "$KEYCLOAK_ADMIN_PASSWORD" ] || [ -z "$KEYCLOAK_PASSWORD" ] ; then
            echo "Generating passwords"
            PASS_STR="$(shift; < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c"${1:-192}")"
            # split the password string into 3 parts
            # 1. database password
            # 2. admin password
            # 3. user password
            
            # use cut instead of substring because substring is not POSIX compliant
            DATABASE_PASSWORD=$(echo "$PASS_STR" | cut -c 1-64)
            export DATABASE_PASSWORD
            echo "Database password: $DATABASE_PASSWORD"
            
            KEYCLOAK_ADMIN_PASSWORD=$(echo "$PASS_STR" | cut -c 65-128)
            export KEYCLOAK_ADMIN_PASSWORD
            echo "Admin password: $KEYCLOAK_ADMIN_PASSWORD"
            
            KEYCLOAK_PASSWORD=$(echo "$PASS_STR" | cut -c 129-192)
            export KEYCLOAK_PASSWORD
            echo "User password: $KEYCLOAK_PASSWORD"
            
            # overwrite the passwords in the .env file
            sed -i -e "s/\(DATABASE_PASSWORD=\).*/\1$DATABASE_PASSWORD/" .env
            sed -i -e "s/\(KEYCLOAK_ADMIN_PASSWORD=\).*/\1$KEYCLOAK_ADMIN_PASSWORD/" .env
            sed -i -e "s/\(KEYCLOAK_PASSWORD=\).*/\1$KEYCLOAK_PASSWORD/" .env
            
            echo "Passwords generated and saved in .env file for sequential runs"
        fi
        
        # use external network if it exists
        
        if [ "$(docker network ls --filter name=pmd-ds -q)" ]; then
            USE_EXTERNAL_PMD_DS_NETWORK="true"
            export USE_EXTERNAL_PMD_DS_NETWORK
            # echo "Creating network pmd-ds"
            # docker network create pmd-ds
        fi
        
        echo "Starting keycloak"
        docker compose up -d
    ;;
    stop)
        echo "Stopping keycloak"
        docker compose down
    ;;
    clean)
        echo "Removing keycloak's docker volumes"
        docker compose rm --volumes
    ;;
    
    get-iat)
        # return an initial access token
        # this token is used to create clients
        # this token is valid for 60 seconds
        # this token is generated only once
        
        ACCESS_TOKEN=$(docker compose -v run --entrypoint=sh curl -c 'curl -s $KEYCLOAK_URL/realms/$KEYCLOAK_REALM/protocol/openid-connect/token -d client_id=$KEYCLOAK_CLIENT -d grant_type=password -d username=$KEYCLOAK_ADMIN -d password=$KEYCLOAK_ADMIN_PASSWORD' | docker compose run -T jq -r '.access_token')

        # we need to export the access token so that it can be used inside the container
        export ACCESS_TOKEN
        
        INITIAL_ACCESS_TOKEN=$(docker compose run --entrypoint=sh curl -c 'curl -s -H "Authorization: Bearer $ACCESS_TOKEN" $KEYCLOAK_URL/admin/realms/$KEYCLOAK_REALM/clients-initial-access -H "Content-Type: application/json" -d "{ \"count\": 1, \"expiration\": 60 }"' | docker compose run -T jq -r '.token')
        echo "$INITIAL_ACCESS_TOKEN"
    ;;
    
    *)
        echo "Usage: $0 {start|stop|clean|get-iat}"
        echo "  start:    starts keycloak"
        echo "  stop:     stops keycloak"
        echo "  clean:    removes keycloak docker volumes"
        echo "  get-iat:  return an initial access token"
        exit 1
    ;;
esac