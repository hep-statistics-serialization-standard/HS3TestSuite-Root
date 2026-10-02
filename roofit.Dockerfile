ARG ROOT_TAG=v6-40-04
FROM registry.cern.ch/hs3-root/root-release:${ROOT_TAG}

ENV PYTHONPATH=/opt/hs3testsuite:${PYTHONPATH}

COPY ./roofit_backend.py /opt/hs3testsuite/hs3suite_backend.py

COPY ./generate-fixtures.sh /usr/local/bin/generate-fixtures
RUN chmod +x /usr/local/bin/generate-fixtures
