#!/bin/sh

set -x


java -jar /opt/wiremock/wiremock.jar \
     --root-dir /var/lib/wiremock \
     --proxy-all="https://connect.redhat.com" \
     --bind-address="0.0.0.0" \
     --record-mappings \
     --verbose &

sleep 5

http --pretty=all --traceback --json POST :8080/api/container/status pid=\"${PROJECT_ID}\" secret=\"${SECRET}\"
http --pretty=all --traceback --json POST :8080/api/container/publish pid=\"${PROJECT_ID}\" secret=\"${SECRET}\" docker_image_digest=\"${DIGEST}\"
http --pretty=all --traceback --json POST :8080/api/container/scanResults pid=\"${PROJECT_ID}\" secret=\"${SECRET}\" docker_image_digest=\"${DIGEST}\"

sleep 5
http --pretty=all --traceback --json POST :8080/__admin/shutdown
