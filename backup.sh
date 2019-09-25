#! /bin/bash
set -euo pipefail

# Check environment
if [ -z "${POSTGRES_DATABASE:-}" ]; then
  echo "POSTGRES_DATABASE was not set"
fi

if [ -z "${POSTGRES_HOST:-}" ]; then
  echo "POSTGRES_HOST was not set"
fi

if [ -z "${POSTGRES_PORT:-}" ]; then
  echo "POSTGRES_HOST was not set"
fi

if [ -z "${POSTGRES_USER:-}" ]; then
  echo "POSTGRES_HOST was not set"
fi

if [ -z "${POSTGRES_PASSWORD:-}" ]; then
  echo "POSTGRES_PASSWORD was not set"
fi

if [ -z "${S3_BUCKET:-}" ]; then
  echo "S3_BUCKET was not set"
fi

if [ -z "${S3_PREFIX:-}" ]; then
  echo "S3_BUCKET was not set"
fi

export PGPASSWORD=${POSTGRES_PASSWORD}

FILENAME=${POSTGRES_DATABASE}_$(date +"%Y-%m-%dT%H:%M:%SZ").dump
echo "Using Filename: ${FILENAME}"

# Backup, compress,
echo "Fetching DB dump..."
pg_dump -Fc -v -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U ${POSTGRES_USER} ${POSTGRES_DATABASE} > ${FILENAME}

SIZE=$(du -h $FILENAME| cut -f1)

# Upload
echo "Backup size: ${SIZE}"
echo "Uploading backup..."

YEAR=$(date +"%Y")
MONTH=$(date +"%m")
DAY=$(date +"%d")

# Upload, expected size param used for large backup (>5G), according to AWS docs.
aws s3 cp ${FILENAME} "s3://$S3_BUCKET/$S3_PREFIX/${YEAR}/${MONTH}/${DAY}/${FILENAME}" --expected-size "${SIZE}"

echo "Done."

rm ${FILENAME}

echo "Local backup file removed."
