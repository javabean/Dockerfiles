#FROM consul:latest
FROM cedrik/baseimage:latest
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

# https://www.consul.io/
# https://hub.docker.com/_/consul/
# https://github.com/hashicorp/docker-consul

# Consul binary & user created in base image

#COPY *.json /usr/local/etc/consul.d/

#VOLUME ["/var/log"]
#VOLUME ["/srv/consul/data", "/usr/local/etc/consul.d"]

# 8300: Server RPC, used for communication between Consul clients and servers for internal request forwarding
# 8301, 8302: Serf LAN and WAN (WAN is used only by Consul servers), used for gossip between Consul agents. LAN is within the datacenter and WAN is between just the Consul servers in all datacenters.
# 8400: CLI
# 8500: HTTP
# 8600: DNS
EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp 53 53/udp

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/consul.sh"]
CMD ["agent", "-server"]
