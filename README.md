# Deploying Red Hat SSO with an Oracle DB datsource on Openshift 4

## Background 

This Document is based on the Official Red Hat Documentation here

   * https://access.redhat.com/documentation/en-us/red_hat_single_sign-on/7.4/html-single/red_hat_single_sign-on_for_openshift_on_openjdk/index#customizing_the_default_behavior_of_the_red_hat_single_sign_on_image

Deploying to Openshift 4

   * https://docs.openshift.com/container-platform/4.8/welcome/index.html

Deploying an image based on this RHEL8/RH-SSO image

   * https://catalog.redhat.com/software/containers/rh-sso-7/sso74-openshift-rhel8/5e7e033d5a1346687697bbd3?container-tabs=gti

In order to do this a Red Hat account is needed

   * https://www.redhat.com/wapps/ugc/register.html?_flowId=register-flow&_flowExecutionKey=e1s1

Oracle Drivers here

   * https://www.oracle.com/database/technologies/appdev/jdbc-ucp-19c-downloads.html



## Deployment is a two step process.

   1. Customising the base container image to incorporate tools and configuration to allow RH-SS) to connect to an ORacle RDBMS (by default it only supports Postgresql). Scripts and resources for doing this are in the **build** folder.
   2. Deploying the customised image with a K8s secret contain the database URL and credentials. Scripts and resources for doing this are in the **deploy** folder.
