FROM remnux/metasploit:latest
LABEL maintainer="zinklandi@gmail.com"

# update the apt-get system
RUN apt-get update -y -qq && apt-get install -y -qq curl

# configure nodejs and npm for the installation
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

# install python dependencies, curl, gnupg2 and tcpdump
RUN apt-get update -y -qq && \
 apt-get install -y -qq python3 python3-pip curl gnupg2 tcpdump \
 nodejs && \
 pip3 install requests

# Get rvm Public Keys
RUN curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -

# install ruby dependencies
RUN apt-get install -y ruby-full
RUN curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install ruby-2.3.3"
RUN /bin/bash -l -c "rvm install ruby-2.5.1"
RUN /bin/bash -l -c "rvm use ruby-2.5.1 --default"
RUN /bin/bash -l -c "source /usr/local/rvm/scripts/rvm"
RUN /bin/bash -l -c "gem install net-ping"
RUN /bin/bash -l -c "gem install bundler"
RUN /bin/bash -l -c "bundle install"
RUN /bin/bash -l -c "source /usr/local/rvm/scripts/rvm && bundle update"
RUN /bin/bash -l -c "which bundle"

# get dependencies
RUN /bin/bash -l -c "BUNDLEJOBS=$(expr $(cat /proc/cpuinfo | grep vendor_id | wc -l) - 1)"
RUN /bin/bash -l -c "bundle config --global jobs $BUNDLEJOBS"

# we don't need the usual metasploit modules for now
RUN rm -rf /opt/msf/modules

# configure the directories
RUN /bin/bash -l -c "mkdir -p '/opt/msf/modules/auxiliary/seclab/'"
RUN /bin/bash -l -c "mkdir -p '/seclab/apt-toolchain/libs'"

# !SECLAB MODULES! add the developed modules to metasploit below
COPY './libs/*' '/seclab/apt-toolchain/libs/'
COPY './*.rb' '/opt/msf/modules/auxiliary/seclab/'
COPY './startup.sh' '/startup.sh'

# setting the environment
ENV PYTHONIOENCODING='UTF-8'

# startup the module
RUN /bin/bash -l -c "chmod -R 777 /seclab/apt-toolchain/libs/"
RUN /bin/bash -l -c "chmod +x /seclab/apt-toolchain/libs/tcp_logger"
RUN /bin/bash -l -c "chmod +x /startup.sh"
CMD /bin/bash -l -c "/seclab/apt-toolchain/libs/tcp_logger -l &" && /bin/bash -l -c "/startup.sh" && /bin/bash -l -c "/seclab/apt-toolchain/libs/tcp_logger -s"
