# update the line below with the repository where you can abtain the base image
FROM registry.redhat.io/rh-sso-7/sso74-openshift-rhel8:7.4-37

USER root

COPY dependencies/sso-extensions.cli /opt/eap/extensions/
COPY dependencies/ojdbc8.jar /opt/eap/extensions/ojdbc8.jar
COPY dependencies/standalone-openshift.xml /opt/eap/standalone/configuration

USER 1001