FROM docker:18.09.3

LABEL PRODUCT=MF2C
LABEL description="Initializes the mF2C Microagent"

RUN apk add jq --no-cache

ADD mf2c-entrypoint.sh /usr/local/bin/mf2c-entrypoint.sh

ENTRYPOINT ["mf2c-entrypoint.sh"]