# FROM alpine:latest
FROM balenalib/raspberry-pi-alpine:latest


# install sqlite, curl, bash (for script)
RUN apk add --no-cache \
    sqlite \
    curl \
    bash \
    openssl \
    sudo \ 
    busybox-suid


ENV DB_FILE /data/db.sqlite3
ENV BACKUP_FILE /db_backup/backup.sqlite3
ENV DROPBOX_ACCESS_TOKEN ""
ENV CRON_TIME "0 5 * * *"
ENV TIMESTAMP false
ENV LOGFILE /app/log/backup.log
ENV DELETE_AFTER 0


# install dropbox uploader script
RUN curl "https://raw.githubusercontent.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh" -o /usr/local/bin/dropbox_uploader.sh && \
    chmod +x /usr/local/bin/dropbox_uploader.sh

# copy backup script to crond daily folder
COPY backup.sh /app/

# copy entrypoint to usr bin
COPY entrypoint.sh /usr/local/bin/entrypoint.sh


RUN mkdir  /app/log/ \
    && chown -R app:app /app/ \
    && chmod -R 777 /app/ \
    && chmod +x /usr/local/bin/entrypoint.sh

RUN addgroup -S -g 201 app && adduser -u 201 -S -G app app
RUN echo "app ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/app && \
    chmod 0440 /etc/sudoers.d/app

USER app
ENTRYPOINT ["entrypoint.sh"]
