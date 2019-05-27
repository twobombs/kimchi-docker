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

# build version
RUN cd /kimchi && ./autogen.sh --system && make all && make install
RUN cd /wok && ./autogen.sh --system && make all && make install

# dpkg version
RUN cd /root && wget https://github.com/kimchi-project/kimchi/releases/download/2.5.0/wok-2.5.0-0.noarch.deb
RUN cd /root && wget https://github.com/kimchi-project/kimchi/releases/download/2.5.0/kimchi-2.5.0-0.noarch.deb
RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y python-cherrypy3 python-jsonschema python-m2crypto python-pam python-lxml python-psutil && apt-get clean all
RUN cd /root && dpkg -i wok-2.5.0-0.noarch.deb && apt install -f -y && dpkg --ignore-depends=python-imaging -i kimchi-2.5.0-0.noarch.deb


# change starup behaviour
COPY run /root/run
RUN chmod 755 /root/run

EXPOSE 8001
ENTRYPOINT /root/run
