FROM cedrik/baseimage:latest
MAINTAINER Cédrik LIME

# OpenJDK

#ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
#RUN echo "/usr/lib/jvm/java-8-openjdk-amd64" > /etc/container_environment/JAVA_HOME

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openjdk-8-jre-headless unzip ca-certificates-java \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& DEBIAN_FRONTEND=noninteractive dpkg-reconfigure ca-certificates-java

# Oracle JDK

#RUN mkdir -p /opt

#RUN cd /opt \
#	&& curl -O -fsSLR --header "Cookie: oraclelicense=accept-securebackup-cookie;" http://download.oracle.com/otn-pub/java/jdk/6u45-b06/jdk-6u45-linux-x64.bin \
#	&& sh jdk-6u45-linux-x64.bin \
#	&& ln -s /opt/jdk1.6.0_45 /opt/jdk6 \
#	&& rm -r jdk-6u45-linux-x64.bin /opt/jdk6/lib/ct.sym /opt/jdk6/src.zip /opt/jdk6/db /opt/jdk6/lib/visualvm \
#	&& cd -

#RUN curl -fsSL --header "Cookie: oraclelicense=accept-securebackup-cookie;" http://download.oracle.com/otn-pub/java/jdk/7u80-b15/server-jre-7u80-linux-x64.tar.gz | tar xzv -C /opt --exclude="jdk1.7.0_80/lib/ct.sym" --exclude="jdk1.7.0_80/src.zip" --exclude="jdk1.7.0_80/db" --exclude="jdk1.7.0_80/lib/visualvm" \
#	&& ln -s /opt/jdk1.7.0_80 /opt/jdk7

#RUN curl -fsSL --header "Cookie: oraclelicense=accept-securebackup-cookie;" http://download.oracle.com/otn-pub/java/jdk/8u92-b14/server-jre-8u92-linux-x64.tar.gz | tar xzv -C /opt --exclude="jdk1.8.0_92/lib/ct.sym" --exclude="jdk1.8.0_92/db" \
#	&& ln -s /opt/jdk1.8.0_92 /opt/jdk8

#VOLUME ["/var/log"]
