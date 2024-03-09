FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive

# RUN apt update && apt install xz-utils

# ARG S6_OVERLAY_VERSION=3.1.0.1
# ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
# RUN tar -xJf /tmp/s6-overlay-noarch.tar.xz -C /tmp
# ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
# RUN tar -xJf /tmp/s6-overlay-x86_64.tar.xz -C /tmp


RUN apt update && \
    apt install -y openssh-server nano htop lsof python3-pip \ 
    sudo figlet lolcat bash-completion  \
    ufw net-tools netcat curl apache2 \
    inetutils-ping php libapache2-mod-php \
    iproute2 default-jre bc build-essential git wireguard zsh make \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev 


RUN service ssh start 
RUN echo 'root:admin' | chpasswd 
RUN echo "figlet -t -c youngstorage | lolcat" >> /etc/bash.bashrc 
RUN echo "echo ''" >> /etc/bash.bashrc 
RUN curl -fsSL https://code-server.dev/install.sh | sh

COPY /index.html /var/www/html/
COPY wg0.conf /etc/wireguard
COPY setup.sh /
RUN chmod +x setup.sh
RUN adduser dep --gecos "" --disabled-password --force-badname 
RUN echo "dep:dep@321" | sudo chpasswd
RUN usermod -aG sudo dep
RUN rm /home/dep/.bashrc
COPY .bashrc /home/dep/

CMD ["./setup.sh"]



