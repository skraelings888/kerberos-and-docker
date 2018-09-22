FROM centos:centos7

USER root
## Instalando Kerberos     ##
RUN yum update -y && yum install -y krb5-libs krb5-auth-dialog krb5-workstation \
sssd realmd adcli oddjob oddjob-mkhomedir openldap-clients pam_ldap nss-pam-ldapd cronie

ENV LANG C.UTF-8

## Adding script to detect the appropriate JAVA_HOME value based on the installed JDK/JRE  ##
RUN { \
                echo '#!/bin/sh'; \
                echo 'set -e'; \
                echo; \
                echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
        } > /usr/local/bin/docker-java-home \
        && chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.x86_64/jre

ENV JAVA_VERSION 8u171

ENV JAVA_CENTOS_VERSION 1.8.0.171-7.b10.el7

RUN set -x \
        && yum install -y \
                java-1.8.0-openjdk-headless-"$JAVA_CENTOS_VERSION" which \
        && [ "$JAVA_HOME" = "$(docker-java-home)" ] \
&& yum clean all && rm -rf /var/cache/yum

## Defining Variables for the Application User   ##
ENV HOME=/home/<USER>
ENV KEYTAB_HOME=/etc/security/keytabs/

ENV HOME=/home/<USER>
ENV APP_HOME=/home/<USER>/<APPLICATION>
ENV PATH $PATH:/home/<USER>/<APPLICATION>/bin
ENV APP_NAME="<APPLICATION>"
ENV APP_PORT="8080"

RUN mkdir /etc/security/keytabs/

### Creating a user for application   ##
RUN groupadd <USER> \
      && useradd <USER> -g <USER> -d /home/<USER>

## Copying Kerberos configuration files and setting correct permissions for the users of the application  ##
ADD krb5.conf /etc/krb5.conf
ADD pirulito.keytab $KEYTAB_HOME/pirulito.keytab
ADD init-keytab.sh /opt/scripts/init-keytab.sh

RUN chown -R <USER>:<USER> $KEYTAB_HOME
RUN chown <USER>:<USER> /etc/krb5.conf

## Exposing ports for application communication and Kerberos   ##
EXPOSE 8080 88 749

## Settings from application ##
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

## Copying the application and script to create kerberos ticket ##
COPY <APPLICATION> $APP_HOME

## Ensure correct permissions for the keytab ##
RUN chown <USER>:<USER> /etc/krb5.conf /opt/scripts/init-keytab.sh
RUN chown -R <USER>:<USER> $APP_HOME
RUN chmod +x $APP_HOME/bin/$APP_NAME

## Switching to Application User ##
USER <USER>

## Dando inicio ao deploy
CMD ["sh", "/opt/scripts/init-keytab.sh"]
