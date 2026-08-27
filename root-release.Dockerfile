FROM registry.cern.ch/root-ci/ubuntu2404:buildready

ARG ROOT_TAG=v6-40-02
ARG ROOT_DIST=Linux-ubuntu24.04-x86_64-gcc13.3
ARG ROOT_BINARY_BASE_URL=https://github.com/root-project/root/releases/download/

WORKDIR /opt

RUN  set -eux; \
    ROOT_VERSION="$(echo $ROOT_TAG | tr - .)";\
    wget -q "$ROOT_BINARY_BASE_URL/${ROOT_TAG}/root_${ROOT_VERSION}.${ROOT_DIST}.tar.gz" \
        -O root.tar.gz; \
    tar -xzf root.tar.gz; \
    rm root.tar.gz; \
    rm -rf /py-venv

ENV ROOTSYS=/opt/root
ENV PATH=$ROOTSYS/bin:$PATH
ENV PYTHONPATH=$ROOTSYS/lib
ENV CLING_STANDARD_PCH=none
