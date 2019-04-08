FROM docker:18.09.3

RUN apk add curl lshw jq bc wget python openssh py-pip usbutils git --no-cache

ADD mf2c-entrypoint.sh /usr/local/bin/mf2c-entrypoint.sh

ENTRYPOINT ["mf2c-entrypoint.sh"]