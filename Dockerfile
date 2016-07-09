FROM dougbtv/asterisk13

# Run scripts
ADD scripts/run.sh /scripts/run.sh

RUN chmod -R 755 /scripts /var/log /etc/asterisk /var/run/asterisk /var/lib/asterisk /var/spool/asterisk && chmod a+rw /etc/passwd /var/log/asterisk /etc/asterisk /var/run/asterisk /var/lib/asterisk /var/spool/asterisk && chown -R root:root /scripts /var/log /etc/asterisk /var/run/asterisk  /var/lib/asterisk /var/spool/asterisk && chmod a+rw /etc/passwd /var/log/asterisk /etc/asterisk /var/run/asterisk /var/lib/asterisk /var/spool/asterisk

#RUN chmod a+rwx /var/lib/asterisk/keys

# Exposed Port SIP
EXPOSE 5060/udp

# Exposed WebRTP
EXPOSE 8088

WORKDIR /etc/asterisk

ENTRYPOINT ["/scripts/run.sh"]

# Set labels used in OpenShift to describe the builder images
LABEL io.k8s.description="Alpine linux based Asterisk Container" \
      io.k8s.display-name="alpine asterisk" \
      io.openshift.expose-services="8088:http,5060:sip" \
      io.openshift.tags="builder,asterisk" \
      io.openshift.min-memory="1Gi" \
      io.openshift.min-cpu="1" \
      io.openshift.non-scalable="false"
