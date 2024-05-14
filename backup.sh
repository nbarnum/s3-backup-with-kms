#!/bin/bash
# Based on AWS Encryption SDK examples doc
# Ref: https://docs.aws.amazon.com/encryption-sdk/latest/developer-guide/crypto-cli-examples.html#cli-example-script

set -euo pipefail

filename=$1
encryptionContext=$2
s3bucket=$3
s3folder=$4
masterKeyProvider="aws-kms"
metadataOutput="/tmp/metadata-$(date +%s)"

function compress(){
    gzip --quiet --keep "$1"
}

function encrypt(){
    # $masterKey is expected to be available as an environment variable
    aws-encryption-cli \
        --encrypt \
        --input "$1" \
        --output "$(dirname "$1")" \
        --metadata-output "$metadataOutput" \
        --wrapping-keys key="$masterKey" provider="$masterKeyProvider" \
        --encryption-context "$encryptionContext" \
        -v
}

function s3put (){
    # copy file argument 1 to s3 location passed into the script.
    aws s3 cp "$1" "${s3bucket}/${s3folder}/$1"
}

# Validate all required arguments are present.
if [ "$filename" ] && [ "$encryptionContext" ] && [ "$s3bucket" ] && [ "$s3folder" ] && [ "$masterKey" ]; then

    # Is $dir a valid directory?
    if ! test -f "$filename" && ! test -f "${filename}.gz"; then
        echo "ERROR: Target file $filename (or compressed ${filename}.gz) does not exist"
        exit 1
    fi

    if ! test -f "${filename}.gz"; then
        echo ">>> Compressed file does not exist, compressing with gzip..."
        compress "$filename"
    fi

    if ! test -f "${filename}.gz.encrypted"; then
        echo ">>> Encrypting ${filename}.gz..."
        encrypt "${filename}.gz"
    fi

    # rm -f "${filename}.gz"

    echo ">>> Pushing ${filename}.gz.encrypted"
    s3put "${filename}.gz.encrypted"

else
    echo "Arguments: <Directory> <encryption context> <s3://bucketname> <s3 folder>"
    echo " and ENV var \$masterKey must be set"
    exit 255
fi
