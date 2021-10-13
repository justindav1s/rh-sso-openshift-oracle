# Deploying Red Hat SSO with an Oracle DB datsource on Openshift 4

## Background 

This document is based on the official Red Hat Documentation here

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

   1. Customising the base container image to incorporate tools and configuration to allow RH-SSO to connect to an Oracle RDBMS (by default it only supports Postgresql). Scripts and resources for doing this are in the **build** folder.
   2. Deploying the customised image with a K8s secret containing the database URL and credentials. Scripts and resources for doing this are in the **deploy** folder.


### Image Build

In the **build** folder there is
   
   * **Dockerfile** : this specifies the build of our new custom image. the first **FROM** line may need to be edited to point at the correct location and/or tag for the base image. The Dockerfile then copies resources out of **dependencies** folder and puts them in the appropriate folders in the image
     * Of note in the **dependencies** folder is the **standaone-openshift.xml**. The contains RH-SSO's base config. This file has been adapted so that RH-SSO can pick up database config from it's container at runtime. This config is injected by a K8s secret, more details on this in the **deploy** section below. Here is part of the **standaone-openshift.xml** concerned with datasource configuration.
     * ```
        <datasource jndi-name="java:jboss/datasources/KeycloakDS" pool-name="KeycloakDS" enabled="true" use-java-context="true">
            <connection-url>${env.DB_URL}</connection-url>
            <driver>oracle</driver>
            <security>
                <user-name>${env.DB_USER}</user-name>
                <password>${env.DB_PASSWORD}</password>
            </security>
        </datasource>
       ```
       Notice the format of the injected variables eg. **${env.DB_USER}**. This means that this image will be mobile it can be used with any Oracle database, eg dev, uat or production. All that changes is the DB config secret provided at deploy time.
   * **build-openshift.sh** : this deploys a BuildConfig template (**docker-build-template.yaml**) to Openshift and performs the Docker build there, tagging the new image and pushing it to a repository.
   * **build-local-docker.sh** : this does a Docker build/tag/push on a local machine, in which only Docker is installed. This can be the quickest most convenient build method.


### Image Deploy

The **deploy** folder contains

   * **deploy.sh** : this script does most of the work of deploying the custom image. It is split into a number of subsections :
      1. Variables are defined, please set them appropriately for the desired environment.
      2. Clean up resources after previous deploys, if necessary.
      3. Set up some policy for the default ServiceAccount.
      4. Create a secret based on some of the variables defined above. This ecret contains the database credentials and URL. They are injected into the container when it runs and refernced by the RH-SSO base config in the **standalone-openshift.xml** file. See above.
      5. Deploy the Openshift template that defines the K8s objects necessary to run and configure our custom image.

When the deployment has finished (usually 1-2 mins), the RH-SSO web console will be available at the URL specified by the **SSO_WEB_HOSTNAME** variable. The admin user credentials will be those specified by the **ADMIN_USER** and **ADMIN_PASSWORD** variables.

Instructions for exploiting the features of RH-SSO can be found here :
  
   * https://access.redhat.com/documentation/en-us/red_hat_single_sign-on/7.4/html/server_administration_guide/index
   * https://access.redhat.com/documentation/en-us/red_hat_single_sign-on/7.4/html/securing_applications_and_services_guide/index
   * https://access.redhat.com/documentation/en-us/red_hat_single_sign-on/7.4/html/server_developer_guide/index