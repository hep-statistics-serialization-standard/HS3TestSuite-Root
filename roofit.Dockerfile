FROM stalbrec/root:e3a793

ENV PYTHONPATH=/opt/hs3testsuite:$ROOTSYS/lib

COPY ./roofit_backend.py /opt/hs3testsuite/hs3suite_backend.py

COPY ./generate-fixtures.sh /usr/local/bin/generate-fixtures
RUN chmod +x /usr/local/bin/generate-fixtures