#!/bin/bash -xe

# clone repo, detect last commit, vendor deps, update specfile
#
#
# NAME: package name
# SOURCE_NAME: sometime the same of NAME
# VERSION: tag, semver
# COMMIT: latest or sha
# REPO: link
# VENDOR: 0 or 1
# NIGHTLY: 0 or 1

check_variable() {
    local var_name=$1
    if [ -z "${!var_name+x}" ]; then
        echo "Error: '$var_name' is not defined."
        exit 1
    fi
}

check_variable NAME
SOURCE_NAME=${SOURCE_NAME:-"$NAME"}
VERSION=${VERSION:-"16"}
COMMIT=${COMMIT:-"latest"}
REPO=${REPO:-"https://github.com/project-gauntlet/$SOURCE_NAME"}
NIGHTLY=${NIGHTLY:-1}

if [ "$NIGHTLY" -eq 0 ]; then
    COMMIT="v${VERSION}"
fi

if [ ! -e "$NAME" ]; then
    git clone --recurse-submodules $REPO $NAME
fi

cd $NAME

# Get latest COMMIT hash if COMMIT is set to latest
if [[ "$COMMIT" == "latest" ]]; then
    COMMIT=$(git rev-parse HEAD)
fi

git reset --hard $COMMIT

# Ensure commit is set to the current head of the local repo
# This is needed because if we reset to a tag, we want the commit to be in the commit field later on (for VERGEN)
COMMIT=$(git rev-parse HEAD)
SHORTCOMMIT=$(echo ${COMMIT:0:7})

COMMITDATE=$(git log -1 --format=%cd --date=format:%Y%m%d)
COMMITDATESTRING=$(git log -1 --format=%cd --date=iso)


for file in ../*.patch; do
    # Check if the glob found any files
    if [ -f "$file" ]; then
        echo "Patching with $file"
        # Add your processing commands here
        git apply $file
    fi
done

cargo vendor >../vendor-config-$SHORTCOMMIT.toml

chmod -x ./vendor/zip/src/spec.rs || true
chmod -x ./vendor/bumpalo/src/lib.rs || true
chmod -x ./vendor/ipnet/src/lib.rs || true
chmod -x ./vendor/alloc-no-stdlib/src/lib.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/backward_references/hash_to_binary_tree.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/backward_references/hq.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/backward_references/mod.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/bit_cost.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/block_split.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/block_splitter.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/brotli_bit_stream.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/cluster.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/compat.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/compress_fragment.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/compress_fragment_two_pass.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/constants.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/dictionary_hash.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/encode.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/histogram.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/literal_cost.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/metablock.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/static_dict_lut.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/utf8_util.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/util.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/vectorization.rs || true
chmod -x ./vendor/brotli-6.0.0/src/enc/writer.rs || true
chmod -x ./vendor/brotli-6.0.0/src/lib.rs || true
chmod -x ./vendor/brotli-decompressor/src/decode.rs || true
chmod -x ./vendor/brotli-decompressor/src/lib.rs || true
chmod -x ./vendor/brotli-decompressor/src/memory.rs || true

tar -pczf ../vendor-$SHORTCOMMIT.tar.gz vendor


cd ..


sed -i "/^Version: / s/.*/Version:        $VERSION^git%{commitdate}.%{shortcommit}/" $NAME.spec
sed -i "/^%global commitdate / s/.*/%global commitdate $COMMITDATE/" $NAME.spec
sed -i "/^%global commit / s/.*/%global commit $COMMIT/" $NAME.spec
