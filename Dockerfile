FROM python:3.8-slim-buster
#FROM alpine:3.12
#RUN apk add --no-cache cron

ENV LANG en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

COPY . /app

RUN apt-get update && apt-get install -y cron curl less tmux jq locales && pip install -r /app/requirements.txt
RUN sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG


RUN ln -s /app/cron.hourly/1badminton-organizer /etc/cron.hourly/1badminton-organizer
RUN rm -f /etc/crontab && ln -s /app/crontab /etc/crontab

RUN echo "Testing…"
RUN /app/badminton.sh

CMD /app/entrypoint.sh 

