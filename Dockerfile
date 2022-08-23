FROM python:3.8-slim-buster

ARG WEB_CREDS
ARG ICAL_TMPL
ARG GCAL_CLI_CACHE
ARG GCAL_CLI_OAUTH
ARG TELEGRAM_BOT_TOKEN
ARG TELEGRAM_CHAT_ID
ARG DEBUG
ARG CLUB_MANAGER_TELEGRAM_NICK
ARG NO_SPAM

#ENV WEB_CREDS=$WEB_CREDS
#ENV ICAL_TMPL=$ICAL_TMPL
#ENV GCAL_CLI_CACHE=$GCAL_CLI_CACHE
#ENV GCAL_CLI_OAUTH=$GCAL_CLI_OAUTH
#ENV TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
#ENV TELEGRAM_CHAT_ID=$TELEGRAM_CHAT_ID
#ENV DEBUG=$DEBUG
#ENV CLUB_MANAGER_TELEGRAM_NICK=$CLUB_MANAGER_TELEGRAM_NICK
#ENV NO_SPAM=$NO_SPAM

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && \
    apt-get install -y curl jq locales && \
    sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG

RUN mkdir -p /app/.auth/.gcalcli && \
    if [ -n "$ICAL_TMPL" ]; then echo "$ICAL_TMPL" >/app/ical.tmpl; fi && \
    if [ -n "$WEB_CREDS" ]; then echo "$WEB_CREDS" >/app/.auth/web-creds; fi && \
    if [ -n "$GCAL_CLI_CACHE" ]; then echo "$GCAL_CLI_CACHE" >/app/.auth/.gcalcli/cache; fi && \
    if [ -n "$GCAL_CLI_OAUTH" ]; then echo "$GCAL_CLI_OAUTH" >/app/.auth/.gcalcli/oauth; fi

COPY ./requirements.txt /app
RUN pip install -r /app/requirements.txt

COPY . /app

RUN /app/badminton.sh 
