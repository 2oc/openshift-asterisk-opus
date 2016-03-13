FROM centos:7
MAINTAINER Joeri van Dooren <ure@mororless.be>

ADD tucny-asterisk.repo /etc/yum.repos.d/tucny-asterisk.repo

RUN rpm --import https://ast.tucny.com/repo/RPM-GPG-KEY-dtucny && yum -y install wget && (cd /tmp; wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm; rpm -ivh /tmp/epel-release-7-5.noarch.rpm) && yum -y install asterisk asterisk-fax asterisk-sip && yum clean all -y && rm -fr /etc/asterisk/*

# Run scripts
ADD scripts/run.sh /scripts/run.sh

RUN chmod -R 755 /scripts /var/log /etc/asterisk /var/run/asterisk && chmod a+rw /etc/passwd /var/log/asterisk /etc/asterisk /var/run/asterisk /var/lib/asterisk /var/spool/asterisk && chown -R root:root /scripts /var/log /etc/asterisk /var/run/asterisk && chmod a+rw /etc/passwd /var/log/asterisk /etc/asterisk /var/run/asterisk /var/lib/asterisk /var/spool/asterisk

# Exposed Port SIP
EXPOSE 5060/udp

# Exposed WebRTP
EXPOSE 8088

WORKDIR /etc/asterisk

ENTRYPOINT ["/scripts/run.sh"]

# Set labels used in OpenShift to describe the builder images
LABEL io.k8s.description="Centos linux based Asterisk Container" \
      io.k8s.display-name="alpine apache php" \
      io.openshift.expose-services="8088:http,5060:sip" \
      io.openshift.tags="builder,asterisk" \
      io.openshift.min-memory="1Gi" \
      io.openshift.min-cpu="1" \
      io.openshift.non-scalable="false"
