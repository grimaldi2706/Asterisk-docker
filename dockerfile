FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Actualizar sistema y preparar repositorios
RUN apt-get clean && apt-get update && apt-get install -y \
  software-properties-common \
  apt-utils \
  gnupg \
  lsb-release && \
  add-apt-repository universe && \
  apt-get update

# Instalar dependencias de Asterisk
RUN apt-get install -y \
  build-essential wget curl git \
  libjansson-dev libxml2-dev libncurses5-dev libssl-dev \
  libsqlite3-dev uuid-dev libnewt-dev libedit-dev \
  libsrtp2-dev ca-certificates

# Crear usuario y directorios
RUN groupadd asterisk && \
  useradd -m -r -d /var/lib/asterisk -c "Asterisk User" -s /usr/sbin/nologin -g asterisk asterisk && \
  mkdir -p /var/spool/asterisk /var/log/asterisk /var/run/asterisk && \
  chown -R asterisk:asterisk /var/lib/asterisk /var/spool/asterisk /var/log/asterisk /var/run/asterisk

# Descargar y compilar Asterisk
WORKDIR /usr/src
RUN wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz && \
  tar xzf asterisk-20-current.tar.gz && \
  cd asterisk-20*/ && \
  #contrib/scripts/get_mp3_source.sh && \
  ./configure && \
  make menuselect && \
  menuselect/menuselect --enable chan_sip menuselect.makeopts && \
  menuselect/menuselect --disable chan_pjsip menuselect.makeopts && \
  make -j$(nproc) && \
  make install && \
  make samples && \
  make config && \
  ldconfig

# Establecer permisos finales
#RUN chown -R asterisk:asterisk /etc/asterisk /var/{lib,log,run,spool}/asterisk

USER asterisk
CMD ["asterisk", "-f"]
