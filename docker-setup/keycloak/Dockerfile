# Workaround
# Adding curl and jq to the keycloak image is a workaround for the following issue:
# https://github.com/keycloak/keycloak/issues/20215
# once the issue is resolved, we can remove this workaround
# and use kcadm.sh instead of curl and jq

FROM registry.access.redhat.com/ubi9 AS ubi-micro-build
RUN mkdir -p /mnt/rootfs
# Install curl and jq
RUN dnf install --installroot /mnt/rootfs curl jq --releasever 9 --setopt install_weak_deps=false --nodocs -y; dnf --installroot /mnt/rootfs clean all

# End of workaround


FROM quay.io/keycloak/keycloak:latest as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:keycloak,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY --from=ubi-micro-build /mnt/rootfs /

# HEALTHCHECK --interval=5s CMD test "$(curl -k -s --fail https://localhost:8443/health/live | jq -r .status)" = "UP"
HEALTHCHECK --interval=5s CMD test "$(curl -k -s --fail http://localhost:8080/health/live | jq -r .status)" = "UP"
# HEALTHCHECK --interval=5s --timeout=10s --start-period=5s CMD test "$(curl -k -s --fail https://localhost:8443/health/live | jq -r .status)" = "UP"

ENV KC_HOSTNAME=localhost
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
