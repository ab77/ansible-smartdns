#!/usr/bin/env bash

if ls $(echo $($(which sniproxy) -V) | sed 's/ /_/g')_*.deb &> /dev/null; then
    exit 0
fi

(git clone https://github.com/dlundquist/sniproxy.git || true)\
  && cd sniproxy\
  && (git pull || true)\
  && git checkout ${1}\
  && ./autogen.sh\
  && dpkg-buildpackage\
  && dpkg -i ../sniproxy_*.deb
