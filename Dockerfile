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

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && \
    apt-get install -y curl jq locales && \
    sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG && \
    mkdir /app

COPY ./requirements.txt /app
RUN pip install -r /app/requirements.txt

COPY . /app

RUN --mount=type=secret,id=ical,target=/app/.config/ical \
    --mount=type=secret,id=web-creds,target=/app/.config/web-creds \
    --mount=type=secret,id=gcalcli-oauth,target=/app/.config/gcalcli-oauth \
    mkdir -p /app/.auth/.gcalcli && \
    cp /app/.config/ical /app/ical.tmpl && \
    cp /app/.config/web-creds /app/.auth/web-creds && \
    cp /app/.config/gcalcli-oauth /app/.auth/.gcalcli/oauth

RUN bash -x /app/badminton.sh
