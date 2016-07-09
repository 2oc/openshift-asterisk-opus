FROM centos:latest
MAINTAINER Gonzalo Marcote "gonzalomarcote@gmail.com"
RUN yum -y update
RUN yum -y install vim tar htop
RUN yum -y install gcc gcc-c++ make wget subversion libxml2-devel ncurses-devel openssl-devel sqlite-devel libuuid-devel vim-enhanced jansson-devel unixODBC unixODBC-devel libtool-ltdl libtool-ltdl-devel subversion speex-devel mysql-devel
WORKDIR /usr/src
RUN svn co http://svn.pjsip.org/repos/pjproject/trunk/ pjproject-trunk
WORKDIR /usr/src/pjproject-trunk
RUN ./configure --libdir=/usr/lib64 --prefix=/usr --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr CFLAGS='-O2 -DNDEBUG'
RUN make dep
RUN make
RUN make install
RUN ldconfig
RUN ldconfig -p | grep pj
WORKDIR /usr/src
RUN wget http://downloads.asterisk.org/pub/telephony/certified-asterisk/certified-asterisk-13.1-current.tar.gz
RUN tar -zxvf certified-asterisk-13.1-current.tar.gz
WORKDIR /usr/src/certified-asterisk-13.1-cert2
RUN sh contrib/scripts/get_mp3_source.sh
COPY menuselect.makeopts /usr/src/certified-asterisk-13.1-cert2/menuselect.makeopts
RUN ./configure CFLAGS='-g -O2 -mtune=native' --libdir=/usr/lib64
RUN make
RUN make install
RUN make samples

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
