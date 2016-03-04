FROM ubuntu:14.04

MAINTAINER Paul Kochetkov <p02p@yandex.ru>

RUN apt-get update
RUN apt-get upgrade -y

# nano
RUN apt-get install nano -y

# GIT
RUN apt-get -y install git

# NodeJS
RUN apt-get -y install nodejs
RUN apt-get -y install npm

#SSH setup
RUN apt-get update && apt-get install -y openssh-server apache2 supervisor
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor

RUN echo 'root:telegram312' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
#>>>>>>>


#Supervisor config
#<<<<<<<
RUN echo "[supervisord]" >> supervisord.conf
RUN echo "nodaemon=true" >> supervisord.conf
RUN echo "" >> supervisord.conf
RUN echo "[program:sshd]" >> supervisord.conf
RUN echo "command=/usr/sbin/sshd -D" >> supervisord.conf
RUN echo "" >> supervisord.conf
RUN echo "[program:server]" >> supervisord.conf
RUN echo "command=cd PNP_WEB_STAT & nodejs server.js >> PNP_WEB_STAT/server.log" >> supervisord.conf

RUN cp supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN cat supervisord.conf
#>>>>>>>


RUN git clone https://github.com/pashna/PNP_WEB_STAT

EXPOSE 22 8181
CMD ["/usr/bin/supervisord"]