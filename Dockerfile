FROM centos

RUN yum install -y java-1.8.0-openjdk && \
    yum clean all && \
    mkdir -p /opt/wiremock/ && \
    mkdir -p /var/lib/wiremock && \
    chown -R 10001:0 /opt/wiremock /var/lib/wiremock && \
    chmod -R 777 /opt/wiremock /var/lib/wiremock && \
    curl -o /opt/wiremock/wiremock.jar http://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-standalone/2.6.0/wiremock-standalone-2.6.0.jar

USER 10001
EXPOSE 8080
ENTRYPOINT java -jar /opt/wiremock/wiremock.jar --bind-address 0.0.0.0 --root-dir /var/lib/wiremock --verbose
