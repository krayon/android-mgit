#!/bin/bash

# Cache some gradle files that may not be easily obtainable

URLs=(
    'https://jcenter.bintray.com/[ORGASPATH]/[PKG]/[VER]/[SHA]/[PKG]-[VER].jar'
    'https://repo1.maven.org/maven2/[ORGASPATH]/[PKG]/[VER]/[PKG]-[VER].jar'
)

files=(
    'org.jetbrains.kotlin/kotlin-annotation-processing-gradle/1.5.31/22eb723bb91329f344d25ed59aaf7b3225ab02f8'
    'org.jetbrains.kotlin/kotlin-reflect/1.5.31/1523fcd842a47da0820cea772b19c51056fec8a9'
)

mkdir -p "${HOME}/.gradle/caches/modules-2/files-2.1/"
cd       "${HOME}/.gradle/caches/modules-2/files-2.1/"

for f in "${files[@]}"; do #{
    org="${f%%/*}"; f="${f#*/}"
    pkg="${f%%/*}"; f="${f#*/}"
    ver="${f%%/*}"; f="${f#*/}"
    sha="${f%%/*}"; f="${f#*/}"
    echo "${org}|${pkg}|${ver}|${sha}"
    orp="${org//./\/}"
    ofn="${pkg}-${ver}.jar"

    for u in "${URLs[@]}"; do #{
        fullurl="${u}"
        fullurl="${fullurl//\[ORG\]/${org}}"
        fullurl="${fullurl//\[PKG\]/${pkg}}"
        fullurl="${fullurl//\[VER\]/${ver}}"
        fullurl="${fullurl//\[SHA\]/${sha}}"
        fullurl="${fullurl//\[ORGASPATH\]/${orp}}"

        echo "[${org}/${pkg}] Trying: ${u}..."
        wget -O "${ofn}" "${fullurl}" && {
            echo "[${org}/${pkg}] Got pkg, verifying..."
            read fsha _ < <(shasum "${ofn}")
            [ "${sha}" == "${fsha}" ] || {
                echo "[${org}/${pkg}] Failed to verify!"
                continue
            }

            echo "[${org}/${pkg}] Verified."

            mkdir -p "${org}/${pkg}/${ver}/${sha}/"
            mv "${ofn}" "${org}/${pkg}/${ver}/${sha}/"
            break
        }
    done #}
done #}

exit 0
