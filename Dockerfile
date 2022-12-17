FROM ubuntu:20.04

ARG RUBY_INSTALL_VERSION=0.8.5
ARG RUBY_VERSION=2.7.7
ARG BUNDLER_VERSION=2.3.26

EXPOSE 4000

WORKDIR /usr/src/app

# Install system dependencies
RUN apt update --quiet && \
    apt install --quiet --yes \
      bison \
      build-essential \
      gnupg \
      libyaml-dev \
      libssl-dev \
      libgdbm-dev \
      libreadline-dev \
      libncurses5-dev \
      libffi-dev \
      make \
      wget \
      zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Install ruby-install
RUN wget -O ruby-install-${RUBY_INSTALL_VERSION}.tar.gz https://github.com/postmodern/ruby-install/archive/v${RUBY_INSTALL_VERSION}.tar.gz && \
    wget https://raw.github.com/postmodern/postmodern.github.io/main/postmodern.asc && \
    gpg --import postmodern.asc && \
    wget https://raw.github.com/postmodern/ruby-install/master/pkg/ruby-install-${RUBY_INSTALL_VERSION}.tar.gz.asc && \
    gpg --verify ruby-install-${RUBY_INSTALL_VERSION}.tar.gz.asc ruby-install-${RUBY_INSTALL_VERSION}.tar.gz && \
    tar -xzvf ruby-install-${RUBY_INSTALL_VERSION}.tar.gz && \
    make -C ruby-install-${RUBY_INSTALL_VERSION} install && \
    rm -rf postmodern.asc ruby-install-${RUBY_INSTALL_VERSION}*

# Install Ruby
RUN ruby-install --system ruby $RUBY_VERSION

# Silence Ruby deprecation warnings.
ENV RUBYOPT=-W:no-deprecated

# Install Node.js and npm
RUN wget -O - https://deb.nodesource.com/setup_18.x | bash - && \
    apt install --quiet --yes nodejs

# Configure RubyGems to skip gem documentation.
RUN echo "gem: --no-document" >> ~/.gemrc

# Install Bundler
RUN gem install bundler --version $BUNDLER_VERSION

# Configure Bundler to use the persistent dependencies cache.
ENV BUNDLE_PATH=/usr/src/dependencies/bundler

# Configure npm to use the persistent dependencies cache.
ENV NPM_CONFIG_CACHE=/usr/src/dependencies/npm

# Create a folder to use as a persistent volume for caching dependencies.
RUN mkdir -p /usr/src/dependencies
