#!/usr/bin/env bash

set -x

PROJECT=redhat-sso
APP=sso
DB_URL="jdbc:oracle:thin:@(description=(address_list=(address=(protocol=tcp)(port=1521)(host=oracle12c.oracle-test.svc.cluster.local)))(connect_data=(SID=ORCLCDB)))"
DB_USER=keycloak
DB_PASSWORD=changeme
IMAGE='quay.io/justindav1s/custom-sso:7.4-oracle'
SSO_WEB_HOSTNAME='custom-sso.apps.sno.openshiftlabs.net'
ADMIN_USER=admin
ADMIN_PASSWORD=changeme

oc delete project $PROJECT
oc new-project $PROJECT 2> /dev/null
while [ $? \> 0 ]; do
    sleep 1
    printf "."
oc new-project $PROJECT 2> /dev/null
done

# or 

# oc delete deployment $APP -n $PROJECT
# oc delete route -l application=$APP -n $PROJECT
# oc delete service -l application=$APP -n $PROJECT
# oc delete secret db-secret -n $PROJECT


oc policy add-role-to-user view system:serviceaccount:${PROJECT}:default  -n $PROJECT

oc create secret generic db-secret \
  --from-literal=DB_USER=$DB_USER \
  --from-literal=DB_PASSWORD=$DB_PASSWORD \
  --from-literal=DB_URL=$DB_URL \
   -n $PROJECT

oc new-app -f sso74-https.yaml \
 -p APPLICATION_NAME=$APP \
 -p SSO_REALM="demorealm" \
 -p SSO_ADMIN_USERNAME=$ADMIN_USER \
 -p SSO_ADMIN_PASSWORD=$ADMIN_PASSWORD \
 -p MEMORY_LIMIT="1Gi" \
 -p HOSTNAME_HTTP="custom-sso.apps.sno.openshiftlabs.net" \
 -p IMAGE_URL=$IMAGE \
 -n $PROJECT
