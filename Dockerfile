FROM twobombs/deploy-nvidia-docker

# install dependancies
RUN apt-get update
RUN export DEBIAN_FRONTEND=noninteractive && apt-get -y install gcc make autoconf automake gettext git pkgconf xsltproc && apt-get clean all
RUN export DEBIAN_FRONTEND=noninteractive && apt-get -y install python3-configobj novnc python3-libvirt libvirt-bin nfs-common qemu-kvm python3-parted python-ethtool sosreport python-ipaddr python3-lxml open-iscsi python3-guestfs libguestfs-tools spice-html5 python3-magic python3-paramiko python3-pil fonts-font-awesome geoip-database gettext nginx-light python-cheetah python3-cherrypy3 python3-ldap python-openssl python3-pam && apt-get clean all
RUN export DEBIAN_FRONTEND=noninteractive && apt-get -y install pep8 pyflakes python3-requests python3-mock bc && apt-get clean all

#python3 wok compatibility
RUN pip3 install cheetah3 && pip3 install psutil && pip3 install websockify && pip3 install jsonschema

# Set a UTF-8 locale - this is needed for some python packages to play nice
RUN apt-get -y install language-pack-en
ENV LANG="en_US.UTF-8"

# fetch code
RUN git clone https://github.com/kimchi-project/kimchi.git
RUN git clone https://github.com/kimchi-project/wok.git

# build
RUN cd /kimchi && ./autogen.sh --system && make all && make install && make check-local && make check
RUN cd /wok && ./autogen.sh --system && make all && make install && make check-local && make check

# change starup behaviour
COPY run /root/run
RUN chmod 755 /root/run

EXPOSE 8001
ENTRYPOINT /root/run
