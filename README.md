# RDS to S3 backups
This docker image starts a scheduled cron job. The cron job creates a dump of a
postgres database on RDS, compresses it and uploads it to S3.

#### How it works in detail

This container performs the following steps when executed:
* Create a compressed dump of the database using `pg_dump`
* Upload the dump to s3

## Usage

Build the container using

```
$ docker build ./ -t im/rds_backups
```

The container can be executed manually using

```
$ docker run -it im/rds_backups
```

Please mind the configuration below.

### Execution role policy

The execution role needs an [permission for RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.IAMPolicy.html) and S3.

The following is a minimal example of a useable role policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "s3:Put*",
      ],
      "Resource": [
        "${s3_bucket_arn}"
      ]
    }
  ]
}
```

`s3_bucket_arn`, the ARN of the bucket to upload the backup to

### Environment

The container requires the following environment variables to be set:

`POSTGRES_DATABASE`, name of the database
`POSTGRES_HOST`, the name of the RDS instance
`POSTGRES_PORT`, the port of the RDS instance (default: 5432)
`POSTGRES_USER`, the database user
`S3_BUCKET`, the name of the S3 bucket to upload the backup to
`S3_PREFIX`, prefix which will be prepended to the upload path (default: `backups`)

## Two words of caution

Please test your backups regularly.

Encrypt your database data!
The backups are not encrypted to quick restore.
