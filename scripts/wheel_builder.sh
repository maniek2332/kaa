#!/bin/bash

set -x -e

cd `dirname $0`/..

DOCKER_IMAGE="quay.io/pypa/manylinux2010_x86_64"
DOCKER_IMAGE_REF="@sha256:d41631c7360a0028876755aebb7036db639c24e7dcdaf3a9e6dcc0e74a681541"

if [ -n "$1" ]
then
    if [ "$1" = "all" ]
    then
        TARGETS="py35 py36 py37 py38"
    else
        TARGETS="$1"
    fi
else
    TARGETS="py37"
fi

mkdir -p ./wheelhouse/

touch _build_version.py
python -c 'import versioneer; versioneer.write_to_version_file("_build_version.py", versioneer.get_versions())'

for PY_VERSION in ${TARGETS}
do
    sudo docker run -i -t -v `pwd`:/host "${DOCKER_IMAGE}${DOCKER_IMAGE_REF}" \
        /bin/bash /host/scripts/docker_wheel_builder.sh ${PY_VERSION}
done

rm _build_version.py
