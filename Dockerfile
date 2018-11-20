FROM python:2.7.15-alpine

RUN apk add --no-cache postgresql-client bzip2 bash
RUN pip install awscli

ENV POSTGRES_DATABASE=
ENV POSTGRES_HOST=
ENV POSTGRES_PORT=5432
ENV POSTGRES_USER=
ENV POSTGRES_PASSWORD=
ENV S3_BUCKET=
ENV S3_PREFIX=backups

ADD backup.sh backup.sh

RUN echo '0  *  *  *  *    bash /backup.sh' > /etc/crontabs/root

CMD /usr/sbin/crond -f -d 8
