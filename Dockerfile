FROM python:3.8-slim-buster

ENV LANG en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN mkdir -p /app/.auth/.gcalcli
COPY . /app

RUN apt-get update && apt-get install -y curl jq locales && pip install -r /app/requirements.txt
RUN sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG


ARG WEB_CREDS
ARG ICAL_TMPL
ARG GCAL_CLI_CACHE
ARG GCAL_CLI_OAUTH
ARG TELEGRAM_BOT_TOKEN
ARG TELEGRAM_CHAT_ID
ARG DEBUG

RUN if [ -n "$ICAL_TMPL" ]; then echo "$ICAL_TMPL" >/app/ical.tmpl; fi
RUN if [ -n "$WEB_CREDS" ]; then echo "$WEB_CREDS" >/app/.auth/web-creds; fi
RUN if [ -n "$GCAL_CLI_CACHE" ]; then echo "$GCAL_CLI_CACHE" >/app/.auth/.gcalcli/cache; fi
RUN if [ -n "$GCAL_CLI_OAUTH" ]; then echo "$GCAL_CLI_OAUTH" >/app/.auth/.gcalcli/oauth; fi

RUN echo "Testing…"
RUN /app/badminton.sh
