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


### Image Build

In the **build** folder there is
   
   * **Dockerfile** : this specifies the build of our new custom image. the first **FROM** line may need to be edited to point at the coreact location and/or tag for the base image. The Dockerfile then copies resources out of **dependencies** folder and puts them in the appropriate folders in the image
     * Of note in the **dependencies** folder is the standaone-openshift.xml. The contains RH-SSOs base config. This file has been adapted so that RH-SSO can pick up database config from the container at runtime. This config is injected by a K8s secret.
     * ```
                <datasource jndi-name="java:jboss/datasources/KeycloakDS" pool-name="KeycloakDS" enabled="true" use-java-context="true">
                    <connection-url>${env.DB_URL}</connection-url>
                    <driver>oracle</driver>
                    <security>
                        <user-name>${env.DB_USER}</user-name>
                        <password>${env.DB_PASSWORD}</password>
                    </security>
                </datasource>
                <drivers>
                    <driver name="h2" module="com.h2database.h2">
                        <xa-datasource-class>org.h2.jdbcx.JdbcDataSource</xa-datasource-class>
                    </driver>                    
                </drivers>
            </datasources>
     * ```
   * **build-openshift.sh** : this deploys a BuildConfig template (**docker-build-template.yaml**) to Openshift and perform the Docker build there, tag the image and dend it to a repository.
   * **build-local-docker.sh** : this does a Docker build/tag/push on a local machine, in which only Docker is installed. This can be the quickest most convenient method.


### Image Deploy

The **deploy** folder contains

   * **deploy.sh** : this script does most of the work of deploying the custom image. At the Top many variales 