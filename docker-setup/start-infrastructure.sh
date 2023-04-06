#! /usr/bin/env bash

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


# Keycloak

(
    cd keycloak || exit
    ./init-keycloak.sh
)

# Setup and launch a PMD-S with OntoDocker
# PMD_SERVER_REPOSITORY_DIR="pmd-server"
# ONTODOCKER_REPOSITORY_DIR="ontodocker"


# # Start Clean
# if [ -d $PMD_SERVER_REPOSITORY_DIR ]
# then
#     (
#         cd $PMD_SERVER_REPOSITORY_DIR || exit
        
#         # Clean docker
#         PROXY_INSTANCE=$(docker ps --format '{{.Names}}' | grep pmd-server-nginx-1)
#         # Check if there is a proxy instance, might not be running
#         if [ -n "$PROXY_INSTANCE" ]
#         then
#             docker-compose down
#         fi

#     #     # Clean files
#     #     git clean -f -d -x
#     #     git checkout main
#     )
# else
#     # git clone 'https://github.com/materialdigital/pmd-server.git' $PMD_SERVER_REPOSITORY_DIR
#     git clone 'https://github.com/Kibubu/pmd-server.git' $PMD_SERVER_REPOSITORY_DIR
# fi


# # Start the proxy in  subshell
# (
#     cd $PMD_SERVER_REPOSITORY_DIR || exit
#     cp compose-templates/docker-compose-nginx.yml docker-compose.yml
#     cp data/nginx/local.conf.template data/nginx/local.conf
# #     docker-compose up -d
# #     # Check whether the service started properly
# #     docker-compose ps
# )


# # Keycloak
# (
#     cd $PMD_SERVER_REPOSITORY_DIR || exit
#     # create separate directory
#     mkdir keycloak

#     # copy the compose templates
#     cp compose-templates/docker-compose-keycloak.yml keycloak/docker-compose.yml
#     # generate random passwords and insert them into the template config
#     PASS_STR="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c"${1:-128}")"
#     sed -e "s/\[password\]/${PASS_STR:0:64}/" -e "s/\[db password\]/${PASS_STR:64}/" config-templates/keycloak_config.json > keycloak/config.json

#     # change into Keycloak directory
#     (
#         cd keycloak || exit
#         python ../scripts/configure.py config.json

#         # start the keycloak service
#         # docker-compose up -d
#         # # check if the service is up and running
#         # docker-compose ps
#     )

#     # ! Replace "sso.domain.de" with the actual URL for the service
#     KEYCLOAK_URL=sso.domain.de

#     # add the nginx configuration from the template
#     sed "s/\[URL\]/${KEYCLOAK_URL}/" data/nginx/keycloak.conf.template > data/nginx/keycloak.conf

#     # Check and adjust the template if necessary
#     # vi data/nginx/keycloak.conf`
# )

# # Ontodocker
# (
#     cd $PMD_SERVER_REPOSITORY_DIR || exit

#     if [ -d $ONTODOCKER_REPOSITORY_DIR ]
#     then
#         (
#             cd $ONTODOCKER_REPOSITORY_DIR || exit
            
#             # # Clean docker
#             # PROXY_INSTANCE=$(docker ps --format '{{.Names}}' | grep pmd-server-nginx-1)
#             # # Check if there is a proxy instance, might not be running
#             # if [ -n "$PROXY_INSTANCE" ]
#             # then
#             #     docker-compose down
#             # fi

#             # # Clean files
#             # git clean -f -d -x
#             # git checkout main
#         )
#     else
#         git clone https://git.material-digital.de/apps/ontodocker.git $ONTODOCKER_REPOSITORY_DIR
#     fi
# )

# (
#     cd $PMD_SERVER_REPOSITORY_DIR || exit
#     cd $ONTODOCKER_REPOSITORY_DIR || exit
    
#     cp docker-compose-prod.yml docker-compose.yml
#     # docker-compose build
#     # docker-compose run --rm -w /app/app -v ${PWD}/flask_app/:/app ontodocker oidc-register --initial-access-token [TOKEN] https://[SSO_URL]/auth/realms/[SSO_REALM] [ONTODOCKER_URL]
#     # docker-compose up -d --build --scale ontodocker=5

#     # ONTODOCKER_URL=ontodocker.domain.de
#     # cd ..
#     # sed "s/\[URL\]/${ONTODOCKER_URL}/" ontodocker/nginx/prod.conf > data/nginx/ontodocker.conf
#     # docker-compose exec nginx nginx -t

# )