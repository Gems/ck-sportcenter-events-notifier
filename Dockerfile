FROM python:3.8-slim-buster
#FROM alpine:3.12
#RUN apk add --no-cache cron

RUN apt-get update && apt-get install -y cron curl less tmux && pip install gcalcli vobject codenamize

COPY . /app

RUN ln -s /app/cron.hourly/1badminton-organizer /etc/cron.hourly/1badminton-organizer
RUN rm -f /etc/crontab && ln -s /app/crontab /etc/crontab

CMD /app/entrypoint.sh 

