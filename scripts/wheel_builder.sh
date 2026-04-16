#!/bin/bash

set -x -e

cd `dirname $0`/..

DOCKER_IMAGE="quay.io/pypa/manylinux_2_28_x86_64"

if [ -n "$1" ]
then
    if [ "$1" = "all" ]
    then
        TARGETS="py36 py37 py38 py39 py310 py311 py312 py313"
    else
        TARGETS="$1"
    fi
else
    TARGETS="py312"
fi

mkdir -p ./wheelhouse/

touch _build_version.py
python -c 'import versioneer; versioneer.write_to_version_file("_build_version.py", versioneer.get_versions())'

(cd kaacore/third_party/bgfx/bx && git checkout include/bx/platform.h)
(cd kaacore/third_party/bgfx/bx && patch -p1) < scripts/bx_relax_glibc_requirement.patch

for PY_VERSION in ${TARGETS}
do
    sudo docker run --rm -it \
        -v `pwd`:/host "${DOCKER_IMAGE}" \
        /bin/bash /host/scripts/docker_wheel_builder.sh ${PY_VERSION}
done

(cd kaacore/third_party/bgfx/bx && git checkout include/bx/platform.h)

rm _build_version.py
