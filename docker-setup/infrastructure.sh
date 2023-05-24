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
        USE_EXTERNAL_PMD_DS_NETWORK="true"
        export USE_EXTERNAL_PMD_DS_NETWORK
        
        # #start global keycloak

        cd keycloak || exit 1
        ./keycloak.sh start
        # Wait until docker report keycloak as healthy
        # by checking the output of docker compose ps with grep

        while [ -z "$(docker compose ps keycloak | grep healthy)" ]; do
            echo "Waiting for keycloak to start"
            sleep 1
        done

        INITIAL_ACCESS_TOKEN="$(./keycloak.sh get-iat)"
        
        echo "Initial Access Token: ${INITIAL_ACCESS_TOKEN}"
        
        cd .. || exit 1
        
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
    
    # provide help
    -h | --help | help | *)
        echo "Usage: $0 [start|stop|clean]"
        echo "  start: starts the infrastructure"
        echo "  stop: stops the infrastructure"
        echo "  clean: removes the infrastructure"
    ;;

esac