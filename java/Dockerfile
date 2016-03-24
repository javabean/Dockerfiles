FROM cedrik/baseimage:latest
MAINTAINER Cédrik LIME

#ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
#RUN echo "/usr/lib/jvm/java-8-openjdk-amd64" > /etc/container_environment/JAVA_HOME

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openjdk-8-jre-headless unzip ca-certificates-java \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& DEBIAN_FRONTEND=noninteractive dpkg-reconfigure ca-certificates-java

#VOLUME ["/var/log"]
