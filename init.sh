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
oc --config='/opt/wiremock/.kube/config' --namespace=${PROJECT_ID} login --token=${SECRET} --insecure-skip-tls-verify localhost:8443
oc --config='/opt/wiremock/.kube/config' --namespace=${PROJECT_ID} project ${PROJECT_ID}
oc --config='/opt/wiremock/.kube/config' --namespace=${PROJECT_ID} describe istag starter-arbitrary-uid:1.0
oc --config='/opt/wiremock/.kube/config' --namespace=${PROJECT_ID} get istag starter-arbitrary-uid:1.0

sleep 2
http --pretty=all --traceback --json POST :8080/__admin/shutdown
sleep 3

sed -i 's/url/urlPath/g' /var/lib/wiremock/mappings/*

git config --global user.email "nobody@nowhere.com"
git config --global user.name "$(id -u)"

git clone https://github.com/jcpowermac/openshift-pipeline-library /tmp/openshift-pipeline-library -b posturl_updates

#git clone https://github.com/RHsyseng/openshift-pipeline-library /tmp/openshift-pipeline-library
cp /tmp/openshift-pipeline-library/tests/jobs/__files/* /var/lib/wiremock/__files/
