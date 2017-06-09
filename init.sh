#!/bin/sh

set -x

#PROJECT_ID="p17633880910e488f5949aab3ad76cd4317542a7a06"
#DIGEST="sha256:144c7752a692dbcfd32339a9c9acd1e56d03de9e1aa617385a630824a4518456"

java -jar /opt/wiremock/wiremock.jar \
     --root-dir /var/lib/wiremock \
     --proxy-all="https://connect.redhat.com" \
     --bind-address="0.0.0.0" \
     --record-mappings \
     --verbose &

sleep 5

http --ignore-stdin --pretty=all --traceback --json POST :8080/api/container/status -- pid=${PROJECT_ID} secret=${SECRET}
http --ignore-stdin --pretty=all --traceback --json POST :8080/api/container/publish -- pid=${PROJECT_ID} secret=${SECRET} docker_image_digest=${DIGEST}
http --ignore-stdin --pretty=all --traceback --json POST :8080/api/container/scanResults -- pid=${PROJECT_ID} secret=${SECRET} docker_image_digest=${DIGEST}

sleep 2
http --pretty=all --traceback --json POST :8080/__admin/shutdown
sleep 3

java -jar /opt/wiremock/wiremock.jar \
     --root-dir /var/lib/wiremock \
     --proxy-all="https://api.rhc4tp.openshift.com" \
     --bind-address="0.0.0.0" \
     --preserve-host-header \
     --https-port 8443 \
     --match-headers="Accept,Content-Type,Authorization" \
     --record-mappings \
     --verbose &

sleep 5
oc login --token=${SECRET} http://localhost:8080
oc describe istag starter-arbitrary-uid:1.0
oc get istag starter-arbitrary-uid:1.0

sleep 2
http --pretty=all --traceback --json POST :8080/__admin/shutdown
sleep 3

sed -i 's/url/urlPath/g' /var/lib/wiremock/mappings/*
