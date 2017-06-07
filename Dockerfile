FROM centos

RUN yum install -y epel-release java-1.8.0-openjdk && \
    yum install -y python2-httpie && \
    yum clean all && \
    mkdir -p /opt/wiremock/ && \
    mkdir -p /var/lib/wiremock && \
    chown -R 10001:0 /opt/wiremock /var/lib/wiremock && \
    chmod -R 777 /opt/wiremock /var/lib/wiremock && \
    curl -o /opt/wiremock/wiremock.jar http://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-standalone/2.6.0/wiremock-standalone-2.6.0.jar

COPY init.sh /opt/wiremock

USER 10001
EXPOSE 8080
ENTRYPOINT java -jar /opt/wiremock/wiremock.jar --bind-address 0.0.0.0 --root-dir /var/lib/wiremock --verbose
