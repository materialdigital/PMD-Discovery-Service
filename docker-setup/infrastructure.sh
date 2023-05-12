#! /usr/bin/env sh

# TODO
# * change default ports
# * cleanup
#   * Proxy
#     * [x] instance
#     * [ ] network
#   * Keycloak
#     * [ ] volume
#     * [ ] network
#     * [ ] db
#     * [ ] instance
# * clean shutdown
# * Check if requierements are met
# * replace fixed container names with generated
# * Fix Keycloak

case "$1" in
    start | up)
        
        # check if network pmd-ds exists
        # if not, create it
        if [ -z "$(docker network ls --filter name=\^pmd-ds -q)" ]; then
            echo "Creating network pmd-ds"
            docker network create pmd-ds
        fi
        
        # #start global keycloak
        INITIAL_ACCESS_TOKEN=""
        (
            cd keycloak || exit
            ./keycloak.sh start
            INITIAL_ACCESS_TOKEN="$(./keycloak.sh get-iat)"
        )
        
        echo "Initial Access Token: ${INITIAL_ACCESS_TOKEN}"
        
        # #start ontodocker
        # (
        #     cd ontodocker || exit
        #     ./ontodocker.sh start
        # )
        
    ;;
    
    stop | down)
    
        (
            cd keycloak || exit
            ./keycloak.sh stop
            # INITIAL_ACCESS_TOKEN=$(./keycloak.sh get_iat)
        )
    ;;
    
    clean | rm)
        
        # check if network pmd-ds exists
        # if yes, remove it
        if [ -n "$(docker network ls --filter name=pmd-ds -q)" ]; then
            echo "Removing network pmd-ds"
            docker network rm pmd-ds
        fi
    ;;
    
    *) echo "Invalid argument: $1"; exit 1 ;;
esac