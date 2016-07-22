FROM centos:7
MAINTAINER Joeri van Dooren <ure@moreorless.io>

RUN yum update -y && \
yum install -y epel-release && \
yum install patch wget git kernel-headers gcc gcc-c++ cpp ncurses ncurses-devel libxml2 libxml2-devel sqlite sqlite-devel openssl-devel newt-devel kernel-devel libuuid-devel net-snmp-devel xinetd tar jansson-devel make bzip2 libsrtp libsrtp-devel -y

WORKDIR /tmp

RUN wget http://downloads.xiph.org/releases/opus/opus-1.1.2.tar.gz && tar xvzf opus-1.1.2.tar.gz

WORKDIR /tmp/opus-1.1.2

RUN ./configure && make && make install

WORKDIR /tmp

RUN git clone https://github.com/seanbright/asterisk-opus

# Download asterisk.
RUN git clone -b 13 --depth 1 https://gerrit.asterisk.org/asterisk
WORKDIR /tmp/asterisk

# Configure
RUN cp ../asterisk-opus/codecs/* codecs/ && cp ../asterisk-opus/formats/* formats/ && patch -p1 < ../asterisk-opus/asterisk.patch

RUN ./configure CFLAGS='-g -O2 -mtune=native' --libdir=/usr/lib64

# Remove the native build option
# from: https://wiki.asterisk.org/wiki/display/AST/Building+and+Installing+Asterisk
#
RUN make menuselect.makeopts
RUN menuselect/menuselect \
  --disable BUILD_NATIVE \
  --enable cdr_csv \
  --enable chan_sip \
  --enable res_http_websocket \
  --enable res_srtp \
  --enable res_hep_rtcp \
  --enable codec_opus \
  --enable format_vp8

RUN make menuselect.makeopts

# Continue with a standard make.
RUN make
RUN make install
RUN make samples
WORKDIR /

# Update max number of open files.
RUN sed -i -e 's/# MAXFILES=/MAXFILES=/' /usr/sbin/safe_asterisk

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
