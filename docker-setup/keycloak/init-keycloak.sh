#! /usr/bin/env bash

cp templates/docker-compose-keycloak.yml docker-compose.yml
PASS_STR="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c"${1:-128}")"
sed -e "s/\[password\]/${PASS_STR:0:64}/" -e "s/\[db password\]/${PASS_STR:64}/" -e "s/\[admin password\]/${PASS_STR:64}/" templates/keycloak_config.json > config.json
python util/configure.py config.json