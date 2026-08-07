FROM registry.cern.ch/root-ci/ubuntu2404:buildready

# commit on root-project/root to build (pin to match the base image's ROOT version)
ARG ROOT_COMMIT_SHA=e3a7938dc31d890c71db86310076d377b6734f2f

# building ROOT
RUN mkdir -p /root-build/root_src /root-build/build /opt/root \
    && cd /root-build/root_src && git init -q \
    && git remote add origin https://github.com/root-project/root.git \
    && git fetch --depth=1 origin ${ROOT_COMMIT_SHA} \
    && git checkout -q FETCH_HEAD \
    && cd /root-build/build && cmake -DCMAKE_INSTALL_PREFIX=/opt/root /root-build/root_src \
    && cd /root-build/build && cmake --build . --target install -j 4 \
    && rm -rf /root-build

ENV ROOTSYS=/opt/root
ENV PATH=$ROOTSYS/bin:$PATH
ENV PYTHONPATH=/opt/hs3testsuite:/$ROOTSYS/lib
ENV CLING_STANDARD_PCH=none

COPY ./roofit_backend.py /opt/hs3testsuite/hs3suite_backend.py

COPY ./generate-fixtures.sh /usr/local/bin/generate-fixtures
RUN chmod +x /usr/local/bin/generate-fixtures