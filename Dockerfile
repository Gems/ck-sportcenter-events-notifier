FROM python:3.8-slim-buster

ENV LANG en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && \
    apt-get install -y curl jq locales && \
    sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG

ARG WEB_CREDS
ARG ICAL_TMPL
ARG GCAL_CLI_CACHE
ARG GCAL_CLI_OAUTH
ARG TELEGRAM_BOT_TOKEN
ARG TELEGRAM_CHAT_ID
ARG DEBUG
ARG CLUB_MANAGER_TELEGRAM_NICK
ARG NO_RUN

RUN mkdir -p /app/.auth/.gcalcli && \
    if [ -n "$ICAL_TMPL" ]; then echo "$ICAL_TMPL" >/app/ical.tmpl; fi && \
    if [ -n "$WEB_CREDS" ]; then echo "$WEB_CREDS" >/app/.auth/web-creds; fi && \
    if [ -n "$GCAL_CLI_CACHE" ]; then echo "$GCAL_CLI_CACHE" >/app/.auth/.gcalcli/cache; fi && \
    if [ -n "$GCAL_CLI_OAUTH" ]; then echo "$GCAL_CLI_OAUTH" >/app/.auth/.gcalcli/oauth; fi

COPY ./requirements.txt /app
RUN pip install -r /app/requirements.txt

COPY . /app

RUN echo "Testing…" && /app/badminton.sh
