#!/bin/bash
set -e -x

# Install a system package required to compile
yum install -y poppler-qt5

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    "${PYBIN}/pip" install -r /io/dev-requirements.txt
    "${PYBIN}/pip" wheel /io/ -w wheelhouse/
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair "$whl" --plat $PLAT -w /io/wheelhouse/
done

# Install packages and test
for PYBIN in /opt/python/*/bin/; do
    "${PYBIN}/pip" install python-poppler-qt5 --no-index -f /io/wheelhouse
    (cd "$HOME"; "${PYBIN}/nosetests" python-poppler-qt5)
done
