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

if [ -z "${S3_BUCKET:-}" ]; then
  echo "S3_BUCKET was not set"
fi

if [ -z "${S3_BUCKET:-}" ]; then
  echo "S3_BUCKET was not set"
fi

if [ -z "${S3_PREFIX:-}" ]; then
  echo "S3_BUCKET was not set"
fi

# Fetch access token for a database we have access to, configured via IAM
export PGPASSWORD=$(aws rds generate-db-auth-token --hostname ${POSTGRES_HOST} --port ${POSTGRES_PORT} --username ${POSTGRES_USER} --region ${REGION})

FILENAME=${POSTGRES_DATABASE}_$(date +"%Y-%m-%dT%H:%M:%SZ").dump
echo "Using Filename: ${FILENAME}"

# Backup, compress,
echo "Fetching DB dump..."
pg_dump -Fc -v -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U ${POSTGRES_USER} "dbname=${POSTGRES_DATABASE} > ${FILENAME}

SIZE=$(du -h $FILENAME| cut -f1)

# Upload
echo "Backup size: ${SIZE}"
echo "Uploading backup..."

# Upload, expected size param used for large backup (>5G), according to AWS docs.
aws s3 cp ${FILENAME} "s3://$S3_BUCKET/$S3_PREFIX/${FILENAME}" --expected-size "${SIZE}"

echo "Done."
