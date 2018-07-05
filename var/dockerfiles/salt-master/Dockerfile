FROM centos:latest

RUN yum install -y epel-release
RUN yum install -y salt-master
RUN mkdir /srv/salt

ADD etc/salt/master /etc/salt/master

EXPOSE 4505
EXPOSE 4506

CMD ["/usr/bin/salt-master", "-l", "debug"]
